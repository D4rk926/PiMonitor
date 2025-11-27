#!/bin/bash

USER_HOME="/home/$USER"
ZIP_URL="https://github.com/D4rk926/PiMonitor/archive/refs/heads/main.zip"

# Letöltés
cd "$USER_HOME/Downloads" || exit
curl -L $ZIP_URL -o PiMonitor.zip

# Kicsomagolás
unzip -o PiMonitor.zip -d "$USER_HOME"
cd "$USER_HOME/PiMonitor-main" || exit

# Telepítés
sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip -y
pip3 install -r requirements.txt
chmod +x PiMonitor.py

# Desktop shortcut frissítése a felhasználóra
DESKTOP_FILE="$USER_HOME/PiMonitor-main/desktop_entry.desktop"
sed -i "s|\$USER|$USER|g" "$DESKTOP_FILE"

mkdir -p "$USER_HOME/.local/share/applications"
cp "$DESKTOP_FILE" "$USER_HOME/.local/share/applications/"
cp "$DESKTOP_FILE" "$USER_HOME/Desktop/"
chmod +x "$USER_HOME/Desktop/desktop_entry.desktop"

# ZIP és felesleges fájlok törlése
rm -f "$USER_HOME/Downloads/PiMonitor.zip"

echo "Telepítés kész! PiMonitor elérhető az asztalon és a home könyvtárban."