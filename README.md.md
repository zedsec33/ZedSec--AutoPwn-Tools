# 🔥 ZedSec AutoPwn Tools

Welcome to the **ZedSec AutoPwn Toolkit** – a collection of fully automated, scriptable tools designed for **bug bounty hunting**, **penetration testing**, and **red teaming engagements**.

> 🧠 **Author**: ZedSec  
> 📧 **Contact**: [hacktheworld.zedsec@yahoo.com](mailto:hacktheworld.zedsec@yahoo.com)  
> 🌐 **Ethical hacking only** – these tools are meant for **authorized** environments.

---

## 🚀 Featured Tool: `zedrecon.sh`

A terminal-based recon and vulnerability scanner designed for fast, deep information gathering and auto-exploitation testing.

### 🔍 Features:
- ✅ Subdomain enumeration (`subfinder`, `amass`)
- ✅ Subdomain takeover detection (`subzy`)
- ✅ Live host detection (`httpx`)
- ✅ Masscan + Nmap port scanning
- ✅ Web crawling (`katana`)
- ✅ Web fuzzing (`ffuf`)
- ✅ Vulnerability scanning with custom templates (`nuclei`)
- ✅ Metasploit integration
- ✅ CSV + log output formatting
- ✅ Fully interactive terminal UI

---

## 📦 Installation (Manual)

> Recommended for Arch Linux, BlackArch, Parrot OS

```
```bash
git clone https://github.com/YOUR_USERNAME/ZedSec-AutoPwn-Tools.git
cd ZedSec-AutoPwn-Tools/tools
chmod +x zedrecon.sh
./zedrecon.sh

```

#### 🛠️ Auto Installer

**Use this for quick setup:**

```
cd ZedSec-AutoPwn-Tools/installers
chmod +x install_zedrecon.sh
./install_zedrecon.sh
```

#### 📁 Folder Structure

ZedSec-AutoPwn-Tools/
├── tools/
│   └── zedrecon.sh
├── installers/
│   └── install_zedrecon.sh
├── docs/
│   └── USAGE.md
├── README.md
├── LICENSE
└── .gitignore

#### 📖 Usage

Run the tool and follow the on-screen menu:

```
./zedrecon.sh
```

**You'll be prompted to:**

    Enter a target

    Run full recon + vuln scanning

    View logs from previous scans

**All output is saved in:**

    output/ → Nmap, masscan, nuclei, etc.

    logs/ → Timestamped scan logs

#### ⚠️ Legal Disclaimer

ZedSec AutoPwn Tools are for authorized testing only.
Misuse may result in criminal charges.
Always get explicit permission before testing any system.

#### 🪪 License

This project is licensed under the MIT License.


#### 🙌 Contributing

Open to contributions!
Feel free to fork, submit issues, or PRs with improvements, templates, or new tools.