#!/bin/bash

# Sicherstellen, dass die Verzeichnisse existieren
mkdir -p debian/guideos-snap-installer/usr/share/applications

# Erstellen der ersten .desktop-Datei
cat > debian/guideos-snap-installer/usr/share/applications/guideos-snap-installer.desktop <<EOL
[Desktop Entry]
Version=1.0
Name=GuideOS Snap Installer
Comment=nstalliert oder deinstalliert Snap und die Snap Store-Komponenten
Exec=/bin/guideos-snap-installer.sh
Icon=guideos-snap-installer
Terminal=false
Type=Application
Categories=GuideOS;
StartupNotify=true
EOL
