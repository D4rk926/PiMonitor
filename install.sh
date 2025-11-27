#!/bin/bash

# 1️⃣ Frissítés
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# 2️⃣ Python telepítés
echo "Installing Python3 and pip..."
sudo apt install python3 python3-pip -y

# 3️⃣ Python csomagok
echo "Installing Python packages..."
pip3 install -r requirements.txt

# 4️⃣ Futtathatóvá tétel
chmod +x PiMonitor.py

# 5️⃣ Desktop shortcut létrehozása
echo "Creating desktop shortcut..."
mkdir -p ~/.local/share/applications
cp desktop_entry.desktop ~/.local/share/applications/

# 6️⃣ Másolás az asztalra
cp desktop_entry.desktop ~/Desktop/
chmod +x ~/Desktop/desktop_entry.desktop

echo "Installation complete! You can run PiMonitor from Desktop or terminal with ./PiMonitor.py"
