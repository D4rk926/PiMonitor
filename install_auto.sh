#!/bin/bash

# ----------------------------
# PiMonitor Auto Installer
# ----------------------------

# Aktuális felhasználó
USER_HOME=$(eval echo "~$USER")

# Telepítési könyvtár
INSTALL_DIR="$USER_HOME/PiMonitor-main"
DESKTOP_FILE="$INSTALL_DIR/PiMonitor.desktop"
DESKTOP_SHORTCUT="$USER_HOME/Desktop/PiMonitor.desktop"

# Ha már van korábbi telepítés, töröljük
if [ -d "$INSTALL_DIR" ]; then
    echo "PiMonitor downloading..."
    rm -rf "$INSTALL_DIR"
fi

# Git clone a legfrissebb verzióból
echo "Downloading from GitHub..."
git clone https://github.com/D4rk926/PiMonitor.git "$INSTALL_DIR"

# Ellenőrizzük, hogy sikerült-e a clone
if [ ! -d "$INSTALL_DIR" ]; then
    echo "Hiba: Nem sikerült letölteni a PiMonitor-t a GitHub-ról!"
    exit 1
fi

# Futtathatóvá tesszük a PiMonitor.py-t
chmod +x "$INSTALL_DIR/PiMonitor.py"

# .desktop fájl létrehozása / %u cseréje
if [ -f "$DESKTOP_FILE" ]; then
    sed -i "s|%u|$USER|g" "$DESKTOP_FILE"
else
    cat <<EOL > "$DESKTOP_FILE"
[Desktop Entry]
Name=Pi Monitor
Comment=Monitor your Raspberry Pi
Exec=python3 $INSTALL_DIR/PiMonitor.py
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Utility;
EOL
fi

# Desktop shortcut létrehozása
cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT"
chmod +x "$DESKTOP_SHORTCUT"

echo "Dowload is ready! Now you can use Pi Monitor by click the application and press execute."