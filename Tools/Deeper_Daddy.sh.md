```
#!/bin/bash

# ┌──────────────────────────────────────────────────────────┐
# │ Author  : ZedSec                                         │
# │ Email   : hacktheworld.zedsec@yahoo.com                  │
# │ Tool    : ZedRecon – Automated Bug Bounty Recon Tool     │
# └──────────────────────────────────────────────────────────┘

BANNER=$(cat <<'EOF'
________                                   ________              .___  .___      
\______ \   ____   ____ ______   __________\______ \ _____     __| _/__| _/__.__.
 |    |  \_/ __ \_/ __ \\____ \_/ __ \_  __ \    |  \\__  \   / __ |/ __ <   |  |
 |    `   \  ___/\  ___/|  |_> >  ___/|  | \/    `   \/ __ \_/ /_/ / /_/ |\___  |
/_______  /\___  >\___  >   __/ \___  >__| /_______  (____  /\____ \____ |/ ____|
        \/     \/     \/|__|        \/             \/     \/      \/    \/\/     
EOF
)

function main_menu {
    clear
    echo "$BANNER"
    echo "              Author: ZedSec | hacktheworld.zedsec@yahoo.com"
    echo ""
    echo "  [1] Start Recon on Target"
    echo "  [2] View Scan Logs"
    echo "  [3] Exit"
    echo ""
    read -p "  Select Option: " opt
    case $opt in
        1) start_recon ;;
        2) view_logs ;;
        3) echo "Exiting ZedRecon. Stay sharp."; exit ;;
        *) echo "Invalid option."; sleep 1; main_menu ;;
    esac
}

function view_logs {
    echo ""
    echo "Available Logs in logs/:"
    ls -lh logs/ | awk '{print "  " $9}'
    echo ""
    read -p "Press [Enter] to return to menu..." enter
    main_menu
}

function start_recon {
    read -p "Enter target domain (e.g., sophos.com): " target
    if [ -z "$target" ]; then
        echo "No target entered. Returning to menu."
        sleep 1
        main_menu
    fi

    # === Recon Script Begins ===
    set -e
    THREADS=60
    DATE=$(date +"%Y-%m-%d_%H-%M")
    LOGFILE="sophos_autopwn_${DATE}.log"
    mkdir -p logs output/{subdomains,httpx,scans,nmap,fuzzing,nuclei,metasploit}
    exec > >(tee -a "logs/$LOGFILE") 2>&1

    function log {
        echo -e "\n[*] $1"
    }

    log "Starting Automated Recon on: $target"
    log "Log file: logs/$LOGFILE"

    # === Dependencies ===
    PKG_DEPENDENCIES=(nmap masscan git jq curl metasploit subfinder amass ffuf)
    AUR_DEPENDENCIES=(katana nuclei subzy httpx)

    for pkg in "${PKG_DEPENDENCIES[@]}"; do
        if ! pacman -Q $pkg &>/dev/null; then
            log "Installing $pkg from pacman..."
            sudo pacman -S --noconfirm $pkg
        fi
    done

    if ! command -v yay &>/dev/null; then
        log "Installing yay..."
        git clone https://aur.archlinux.org/yay.git
        cd yay && makepkg -si --noconfirm && cd ..
    fi

    for aur_pkg in "${AUR_DEPENDENCIES[@]}"; do
        if ! command -v $aur_pkg &>/dev/null; then
            log "Installing $aur_pkg from AUR..."
            yay -S --noconfirm $aur_pkg
        fi
    done

    # === Subdomain Enumeration ===
    log "Running Subfinder & Amass..."
    subfinder -d $target -all -silent -o output/subdomains/subfinder.txt
    amass enum -passive -d $target -o output/subdomains/amass.txt
    cat output/subdomains/*.txt | sort -u > output/subdomains/all.txt

    # === Subdomain Takeover Detection ===
    log "Checking for Takeovers with Subzy..."
    subzy run --targets output/subdomains/all.txt --hide_fails > output/subdomains/takeovers.txt

    # === Live Host Discovery ===
    log "Running httpx for HTTP probing..."
    httpx -l output/subdomains/all.txt -threads $THREADS -status-code -title -tech-detect -json -o output/httpx/live_hosts.json
    jq -r '.url' output/httpx/live_hosts.json | sort -u > output/httpx/live_hosts.txt

    # === IP Extraction for Port Scans ===
    log "Extracting IPs for port scan..."
    cut -d '/' -f3 output/httpx/live_hosts.txt | grep -Eo '([0-9]+\.){3}[0-9]+' | sort -u > output/scans/ips.txt

    # === Masscan + Format Conversion for Nmap ===
    log "Running masscan..."
    masscan -p1-65535,U:1-65535 -iL output/scans/ips.txt --rate 1000 -oG output/scans/masscan.gnmap
    awk '/Ports:/{print $2}' output/scans/masscan.gnmap | sort -u > output/scans/targets.txt

    # === Service Enumeration with Nmap ===
    log "Running nmap on discovered ports..."
    nmap -sC -sV -Pn -T4 -iL output/scans/targets.txt -oA output/nmap/nmap_results

    # === Web Crawling with Katana ===
    log "Running katana crawler..."
    katana -list output/httpx/live_hosts.txt -d 5 -jc -kf -o output/fuzzing/katana.txt

    # === Fuzzing Web Content ===
    log "Running FFUF on base paths..."
    for url in $(cat output/httpx/live_hosts.txt); do
        ffuf -u "$url/FUZZ" -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,403,500 -t 100 -of json -o output/fuzzing/$(echo $url | sed 's/[:\/]/_/g').json
    done

    # === Vulnerability Scanning via Nuclei ===
    log "Running Nuclei with extended templates..."
    nuclei -update-templates
    nuclei -l output/httpx/live_hosts.txt -severity critical,high,medium -c $THREADS -o output/nuclei/findings.txt

    # === Metasploit (HTTP title scan only) ===
    log "Executing basic Metasploit module..."
    cat << EOF > output/metasploit/sophos_autopwn.rc
use auxiliary/scanner/http/title
set RHOSTS file:output/scans/targets.txt
run
exit
EOF
    msfconsole -r output/metasploit/sophos_autopwn.rc -q > output/metasploit/results.txt

    # === JSON to CSV Conversion for Reporting ===
    log "Converting httpx results to CSV..."
    jq -r '[.host, .url, .title, .status_code, (.technologies | join(","))] | @csv' output/httpx/live_hosts.json > output/httpx/live_hosts.csv

    log "All scans complete. Output folders populated."

    log "KEY RESULTS:"
    log "→ Subdomains:        output/subdomains/all.txt"
    log "→ Takeover Checks:   output/subdomains/takeovers.txt"
    log "→ Live Hosts:        output/httpx/live_hosts.txt"
    log "→ IPs for Scanning:  output/scans/ips.txt"
    log "→ Masscan Output:    output/scans/masscan.gnmap"
    log "→ Nmap Output:       output/nmap/nmap_results.nmap"
    log "→ Katana Crawl:      output/fuzzing/katana.txt"
    log "→ FFUF Results:      output/fuzzing/"
    log "→ Nuclei Findings:   output/nuclei/findings.txt"
    log "→ Metasploit Output: output/metasploit/results.txt"
    log "→ HTTPX CSV Report:  output/httpx/live_hosts.csv"
    # === Recon Script Ends ===

    read -p "Press [Enter] to return to menu..." enter
    main_menu
}

main_menu

```