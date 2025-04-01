#!/bin/bash

# === ZedSec Tool Renamer ===
# Converts all references and filenames from Deeper_Daddy.sh to Deeper_Daddy.sh

echo "[*] Renaming main script..."
find . -type f -name 'Deeper_Daddy.sh' -exec mv {} tools/Deeper_Daddy.sh \;

echo "[*] Renaming installer script..."
find . -type f -name 'install_Deeper_Daddy.sh' -exec mv {} installers/install_Deeper_Daddy.sh \;

echo "[*] Replacing all text references to 'Deeper_Daddy.sh' with 'Deeper_Daddy.sh'..."
grep -rl 'Deeper_Daddy.sh' . | xargs sed -i 's/Deeper_Daddy.sh/Deeper_Daddy.sh/g'

echo "[*] Replacing all text references to 'install_Deeper_Daddy.sh' with 'install_Deeper_Daddy.sh'..."
grep -rl 'install_Deeper_Daddy.sh' . | xargs sed -i 's/install_Deeper_Daddy.sh/install_Deeper_Daddy.sh/g'

echo "[*] Renaming all mentions inside README.md and USAGE.md..."
grep -rl 'Deeper_Daddy' . | xargs sed -i 's/Deeper_Daddy/Deeper_Daddy/g'

echo "[+] Rename complete. Your repo is now fully using: Deeper_Daddy.sh"
