#!/bin/bash

# ----------------------------
# PiMonitor Auto Installer
# ----------------------------

# Aktuális felhasználó HOME könyvtára
USER_HOME=$(eval echo "~$USER")

# Telepítési könyvtár
INSTALL_DIR="$USER_HOME/PiMonitor-main"
DESKTOP_FILE="$INSTALL_DIR/PiMonitor.desktop"
DESKTOP_SHORTCUT="$USER_HOME/Desktop/PiMonitor.desktop"

# Ha már van korábbi telepítés, töröljük az egész mappát
if [ -d "$INSTALL_DIR" ]; then
    echo "Old PiMonitor installation found. Removing..."
    rm -rf "$INSTALL_DIR"
fi

# Git clone a legfrissebb verzióból
echo "Downloading PiMonitor from GitHub..."
git clone https://github.com/D4rk926/PiMonitor.git "$INSTALL_DIR"

# Ellenőrizzük, hogy sikerült-e a clone
if [ ! -d "$INSTALL_DIR" ]; then
    echo "ERROR: Could not download PiMonitor from GitHub!"
    exit 1
fi

# →→→ TÖRLÉS: MINDENT törlünk a mappában, KIVÉVE a PiMonitor.py-t ←←←
echo "Cleaning installation folder (keeping only PiMonitor.py)..."

find "$INSTALL_DIR" -mindepth 1 -maxdepth 1 ! -name "PiMonitor.py" -exec rm -rf {} \;

# Futtathatóvá tesszük a PiMonitor.py-t
chmod +x "$INSTALL_DIR/PiMonitor.py"

# .desktop fájl létrehozása
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

# Desktop shortcut létrehozása
cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT"
chmod +x "$DESKTOP_SHORTCUT"

echo "Download ready! You can now launch Pi Monitor from your Desktop."
