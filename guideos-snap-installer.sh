#!/bin/bash
# snap-manager.sh – Snap in GuideOS verwalten
# GUI per Zenity, Snap installieren/deinstallieren, AppArmor prüfen, Menüeinträge korrekt verlinken

# Passwortabfrage mit Zenity
PASS=$(zenity --password --title="Sudo Passwort eingeben" \
              --text="Bitte gib Dein Sudo-Passwort ein:")

if [ -z "$PASS" ]; then
    zenity --error --text="Es wurde kein Passwort eingegeben. Das Skript wird beendet."
    exit 1
fi

run_sudo() {
    echo "$PASS" | sudo -S "$@"
}

# Sudo-Test
if ! echo "$PASS" | sudo -S -v &>/dev/null; then
    zenity --error --text="Falsches Sudo-Passwort. Das Skript wird beendet."
    exit 1
fi

USERNAME="${SUDO_USER:-$(whoami)}"

# Willkommensinfo
zenity --info --title="GuideOS-Snap-Installer" --width=400 \
       --text="INFO: Snap ist ein universelles Paketformat, das Programme in Container packt und plattformübergreifend funktioniert.\n\nWeiter mit der Auswahl..."

# Prüfe, ob Snap vorhanden
is_snap_installed() {
    if command -v snap &> /dev/null; then
        return 0
    else
        return 1
    fi
}

if is_snap_installed; then
    ACTION=$(zenity --list --title="Snap Manager" --column="Aktion" "Deinstallieren" \
             --text="Snap ist bereits installiert.\n\nMöchtest Du Snap deinstallieren?")

    if [ -z "$ACTION" ]; then
        exit 0
    fi

    if [ "$ACTION" = "Deinstallieren" ]; then
        (
            echo "10"; sleep 1
            echo "# Entferne Snap Store..."; run_sudo snap remove snap-store > /dev/null 2>&1
            echo "50"; sleep 1
            echo "# Entferne GNOME Software Plugin..."; run_sudo apt remove -y gnome-software-plugin-snap > /dev/null 2>&1
            echo "90"; sleep 1
            echo "# Entferne Snapd..."; run_sudo apt purge -y snapd > /dev/null 2>&1
            echo "100"; sleep 1
        ) | zenity --progress --title="Snap Deinstallation" --width=400 \
                   --text="Deinstallation wird durchgeführt..." \
                   --no-cancel --auto-close --pulsate

        if [ $? -eq 0 ]; then
            zenity --info --title="Snap Deinstallation" --width=300 \
                   --text="Snap wurde erfolgreich deinstalliert.\n\nBitte starte das System neu!"
        else
            zenity --error --title="Fehler bei Deinstallation" --width=300 \
                   --text="Es ist ein Fehler aufgetreten."
        fi
    fi
else
    ACTION=$(zenity --list --title="Snap Manager" --column="Aktion" "Installieren" \
             --text="Snap ist nicht installiert.\n\nMöchtest Du Snap installieren?")

    if [ -z "$ACTION" ]; then
        exit 0
    fi

    if [ "$ACTION" = "Installieren" ]; then

        (
            echo "5"; sleep 1
            echo "# Installiere AppArmor-Komponenten..."; run_sudo apt install -y apparmor apparmor-utils > /dev/null 2>&1
            echo "10"; sleep 1
            echo "# Aktualisiere Paketliste..."; run_sudo apt update > /dev/null 2>&1
            echo "30"; sleep 1
            echo "# Installiere Snapd und Plugin..."; run_sudo apt install -y snapd gnome-software gnome-software-plugin-snap > /dev/null 2>&1
            echo "35"; sleep 1
            echo "# Erstelle /snap Symlink..."; run_sudo ln -sfn /var/lib/snapd/snap /snap
            echo "40"; sleep 1
            echo "# Setze PATH dauerhaft..."; 
            run_sudo bash -c 'echo -e "# Snap PATH\nif [ -d \"/snap/bin\" ] && ! echo \"$PATH\" | grep -q \"/snap/bin\" ; then\n  export PATH=\"$PATH:/snap/bin\"\nfi" > /etc/profile.d/snap_path.sh'
            run_sudo chmod +x /etc/profile.d/snap_path.sh
            echo "50"; sleep 1
            echo "# Aktiviere snapd-Dienst..."; run_sudo systemctl enable --now snapd.service > /dev/null 2>&1
            echo "70"; sleep 1
            echo "# Richte automatische Menü-Verlinkung über systemd ein..."

            run_sudo bash -c '
cat > /usr/local/bin/snap-desktop-sync.sh <<EOF
#!/bin/bash
ln -sfn /var/lib/snapd/desktop/applications/*.desktop /usr/share/applications/
EOF
chmod +x /usr/local/bin/snap-desktop-sync.sh

cat > /etc/systemd/system/snap-desktop-sync.service <<EOF
[Unit]
Description=Verlinkt Snap-Desktop-Dateien ins Menü

[Service]
Type=oneshot
ExecStart=/usr/local/bin/snap-desktop-sync.sh
EOF

cat > /etc/systemd/system/snap-desktop-sync.path <<EOF
[Unit]
Description=Überwacht Snap-Desktop-Dateien und verlinkt sie

[Path]
PathChanged=/var/lib/snapd/desktop/applications
Unit=snap-desktop-sync.service
EOF

systemctl daemon-reexec
systemctl enable --now snap-desktop-sync.path
'

            echo "90"; sleep 1
            echo "# Führe sofort Verlinkung aus (Live-System-Kompatibilität)..."
            run_sudo /usr/local/bin/snap-desktop-sync.sh

            echo "100"; sleep 1
        ) | zenity --progress --title="Snap Installation" --width=400 \
                   --text="Installation von Snap-Komponenten läuft..." \
                   --no-cancel --auto-close --pulsate

        if [ $? -eq 0 ]; then
            if getent group snap &> /dev/null; then
                run_sudo usermod -aG snap "$USERNAME"
                zenity --info --title="Installation abgeschlossen" --width=300 \
                       --text="Snap wurde erfolgreich installiert.\n\nDer Benutzer '$USERNAME' wurde zur Snap-Gruppe hinzugefügt.\n\nBitte starte das System neu!"
            else
                zenity --info --title="Installation abgeschlossen" --width=300 \
                       --text="Snap wurde erfolgreich installiert.\n\nBitte starte das System neu!"
            fi
        else
            zenity --error --title="Fehler bei Installation" --width=300 \
                   --text="Es ist ein Fehler während der Installation aufgetreten."
        fi
    fi
fi

exit 0
