#!/bin/bash
# snap-manager.sh
# Dieses Skript installiert oder deinstalliert Snap und zugehörige Komponenten.
# Es fragt interaktiv nach einem Sudo-Passwort und verwendet den aufrufenden Benutzer
# (aus SUDO_USER), um diesen ggf. der Snap-Gruppe hinzuzufügen.

# Passwortabfrage mittels Zenity
PASS=$(zenity --password --title="Sudo Passwort eingeben" \
              --text="Bitte gib Dein Sudo-Passwort ein:")

# Falls kein Passwort eingegeben wurde, abbrechen.
if [ -z "$PASS" ]; then
    zenity --error --text="Es wurde kein Passwort eingegeben. Das Skript wird beendet."
    exit 1
fi

# Funktion zum Ausführen von Befehlen mit sudo unter Verwendung des eingegebenen Passworts
run_sudo() {
    echo "$PASS" | sudo -S "$@"
}

# Überprüfe, ob das angegebene Passwort korrekt ist
if ! echo "$PASS" | sudo -S -v &>/dev/null; then
    zenity --error --text="Falsches Sudo-Passwort. Das Skript wird beendet."
    exit 1
fi

# Den Benutzernamen ermitteln: Wenn das Skript mit sudo aufgerufen wurde, ist SUDO_USER gesetzt
USERNAME="${SUDO_USER:-$(whoami)}"

# Begrüßungsinfo (optional)
zenity --info --title="GuideOS-Snap-Installer" --width=400 \
       --text="INFO: Snap ist ein universelles Paketformat, das Programme in Container packt und plattformübergreifend funktioniert.\n\nWeiter mit der Auswahl..."

# Funktion zur Überprüfung, ob Snap installiert ist
is_snap_installed() {
    if command -v snap &> /dev/null; then
        return 0  # Snap ist installiert
    else
        return 1  # Snap ist nicht installiert
    fi
}

# Hauptablauf: Je nachdem, ob Snap bereits installiert ist oder nicht.
if is_snap_installed; then
    # Nur die Option "Deinstallieren" anbieten.
    ACTION=$(zenity --list --title="Snap Manager" --column="Aktion" "Deinstallieren" \
                     --text="Snap ist bereits installiert.\n\nMöchtest Du Snap deinstallieren?")
    # Wenn kein Wert ausgewählt wurde (Fenster geschlossen), beenden.
    if [ -z "$ACTION" ]; then
        exit 0
    fi

    if [ "$ACTION" = "Deinstallieren" ]; then
        (
            echo "10"; sleep 1
            echo "# Entferne Snap Store..."; run_sudo snap remove snap-store > /dev/null 2>&1
            echo "50"; sleep 1
            echo "# Entferne GNOME Software Plugin für Snap..."; run_sudo apt remove -y gnome-software-plugin-snap > /dev/null 2>&1
            echo "90"; sleep 1
            echo "# Entferne Snap..."; run_sudo apt purge -y snapd > /dev/null 2>&1
            echo "100"; sleep 1
        ) | zenity --progress --title="Snap Deinstallation" --width=400 \
                   --text="Deinstallation von Snap und zugehörigen Komponenten wird durchgeführt..." \
                   --no-cancel --auto-close --pulsate

        if [ $? -eq 0 ]; then
            zenity --info --title="Snap Deinstallation" --width=300 \
                   --text="Snap und die zugehörigen Komponenten wurden erfolgreich deinstalliert.\n\nBitte starte das System neu!"
        else
            zenity --error --title="Snap Deinstallation" --width=300 \
                   --text="Es ist ein Fehler während der Deinstallation aufgetreten."
        fi
    fi
else
    # Nur die Option "Installieren" anbieten.
    ACTION=$(zenity --list --title="Snap Manager" --column="Aktion" "Installieren" \
                     --text="Snap ist nicht installiert.\n\nMöchtest Du Snap installieren?")
    # Wenn kein Wert ausgewählt wurde (Fenster geschlossen), beenden.
    if [ -z "$ACTION" ]; then
        exit 0
    fi

    if [ "$ACTION" = "Installieren" ]; then
        (
            echo "10"; sleep 1
            echo "# Aktualisiere Paketliste..."; run_sudo apt update > /dev/null 2>&1
            echo "30"; sleep 1
            echo "# Installiere Snap..."; run_sudo apt install -y snapd > /dev/null 2>&1
            echo "60"; sleep 1
            echo "# Installiere GNOME Software Plugin für Snap..."; run_sudo apt install -y gnome-software-plugin-snap > /dev/null 2>&1
            echo "80"; sleep 1
            echo "# Installiere Snap Store..."; run_sudo snap install snap-store > /dev/null 2>&1
            echo "100"; sleep 1
        ) | zenity --progress --title="Snap Installation" --width=400 \
                   --text="Installation von Snap und den zugehörigen Komponenten wird durchgeführt..." \
                   --no-cancel --auto-close --pulsate

        if [ $? -eq 0 ]; then
            if getent group snap &> /dev/null; then
                run_sudo usermod -aG snap "$USERNAME"
                zenity --info --title="Snap Installation" --width=300 \
                       --text="Snap und die Komponenten wurden erfolgreich installiert.\n\nDer Benutzer '$USERNAME' wurde zur Snap-Gruppe hinzugefügt.\n\nBitte starte das System neu!"
            else
                zenity --info --title="Snap Installation" --width=300 \
                       --text="Snap und die Komponenten wurden erfolgreich installiert.\n\nBitte starte das System neu!"
            fi
        else
            zenity --error --title="Snap Installation" --width=300 \
                   --text="Es ist ein Fehler während der Installation aufgetreten."
        fi
    fi
fi

exit 0

