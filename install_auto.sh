#!/bin/bash

# Felhasználó home könyvtára
USER_HOME="/home/$USER"

# GitHub ZIP URL
ZIP_URL="https://github.com/D4rk926/PiMonitor/archive/refs/heads/main.zip"

# 1️⃣ Letöltés a Downloads mappába
cd "$USER_HOME/Downloads" || exit
curl -L $ZIP_URL -o PiMonitor.zip

# 2️⃣ Kicsomagolás a home-ba
unzip -o PiMonitor.zip -d "$USER_HOME"
cd "$USER_HOME/PiMonitor-main" || exit

# 3️⃣ Telepítés
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip -y
pip3 install -r requirements.txt
chmod +x PiMonitor.py

# 4️⃣ Desktop shortcut létrehozása
mkdir -p "$USER_HOME/.local/share/applications"
cp desktop_entry.desktop "$USER_HOME/.local/share/applications/"

# Másolás az asztalra és futtathatóvá tétel
cp desktop_entry.desktop "$USER_HOME/Desktop/"
chmod +x "$USER_HOME/Desktop/desktop_entry.desktop"

# 5️⃣ Takarítás
rm "$USER_HOME/Downloads/PiMonitor.zip"

echo "Telepítés kész! PiMonitor elérhető az asztalon és a home könyvtárban."
