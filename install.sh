#!/bin/bash
set -e

echo "Installing PiMonitor..."

# Install required python packages
pip3 install psutil

# Install desktop icon
mkdir -p ~/.local/share/applications
cp desktop_entry.desktop ~/.local/share/applications/PiMonitor.desktop

# Make PiMonitor.py executable
chmod +x PiMonitor.py

echo "Installation complete!"
echo "You can now find PiMonitor in your menu."
