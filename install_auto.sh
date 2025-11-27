#!/bin/bash

# ----------------------------
# PiMonitor Auto Installer
# ----------------------------

# Aktuális felhasználó
USER_HOME=$(eval echo "~$USER")

# Alap könyvtárak
DOWNLOADS_DIR="$USER_HOME/Downloads"
INSTALL_DIR="$USER_HOME/PiMonitor-main"
DESKTOP_FILE="$INSTALL_DIR/PiMonitor.desktop"
DESKTOP_SHORTCUT="$USER_HOME/Desktop/PiMonitor.desktop"

# Ellenőrizzük, hogy létezik-e a telepítendő mappa
if [ ! -d "$DOWNLOADS_DIR/PiMonitor-main" ]; then
    echo "Hiba: PiMonitor-main mappa nem található a Downloads könyvtárban!"
    exit 1
fi

# Ha már van korábbi telepítés, töröljük
if [ -d "$INSTALL_DIR" ]; then
    echo "Korábbi PiMonitor telepítés törlése..."
    rm -rf "$INSTALL_DIR"
fi

# Áthelyezés home könyvtárba
mv "$DOWNLOADS_DIR/PiMonitor-main" "$INSTALL_DIR"

# Ellenőrizzük, hogy a PiMonitor.py futtatható
chmod +x "$INSTALL_DIR/PiMonitor.py"

# .desktop fájl elkészítése / %u cseréje
if [ -f "$DESKTOP_FILE" ]; then
    sed -i "s|%u|$USER|g" "$DESKTOP_FILE"
else
    # Ha nincs, készítsünk egy alap desktop fájlt
    cat <<EOL > "$DESKTOP_FILE"
[Desktop Entry]
Name=PiMonitor
Comment=Monitor your Raspberry Pi
Exec=python3 $INSTALL_DIR/PiMonitor.py
Icon=$INSTALL_DIR/icon.png
Terminal=false
Type=Application
Categories=Utility;
EOL
fi

# Másoljuk a Desktop-ra a shortcutot
cp "$DESKTOP_FILE" "$DESKTOP_SHORTCUT"
chmod +x "$DESKTOP_SHORTCUT"

# Töröljük a ZIP-et, ha van
if [ -f "$DOWNLOADS_DIR/PiMonitor-main.zip" ]; then
    rm "$DOWNLOADS_DIR/PiMonitor-main.zip"
fi

echo "Dowload is ready! Now you can use Pi Monitor by click the application and press execute."
