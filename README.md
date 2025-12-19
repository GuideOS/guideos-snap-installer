```markdown
# GuideOS Snap-Manager

## Übersicht
Der **GuideOS Snap-Manager** ist ein Zenity-basiertes Bash-Skript zur komfortablen **Installation und Deinstallation von Snap** über eine grafische Oberfläche.  
Es prüft automatisch, ob Snap bereits installiert ist, und bietet je nach Status die passende Aktion (Installieren oder Deinstallieren) an.  
Der Fortschritt wird in einem GUI-Fenster angezeigt, inklusive Statusmeldungen und Erfolgs-/Fehlerdialogen.

- **Autor:** evilware666  
- **Version:** 1.1  
- **Datum:** 19.12.2025  
- **Lizenz:** MIT  

---

## Voraussetzungen
- **Linux-System** mit Bash und `zenity` installiert  
- **Sudo-Rechte** (Passwort wird beim Start abgefragt)  
- Paketmanager: `apt` (Debian/Ubuntu-basiert)  
- Systemd für Dienstverwaltung  

---

## Installation
1. Skript herunterladen und speichern, z. B. unter `/usr/local/bin/snap-manager.sh`.
2. Datei ausführbar machen:
   ```bash
   chmod +x /usr/local/bin/snap-manager.sh
   ```
3. Sicherstellen, dass `zenity` installiert ist:
   ```bash
   sudo apt install zenity
   ```

---

## Nutzung
Starte das Skript im Terminal:
```bash
./snap-manager.sh
```

### Ablauf:
- **Passwortabfrage:** Eingabe des Sudo-Passworts zur Validierung.  
- **Statusprüfung:** Ermittelt, ob Snap installiert ist.  
- **Aktion:**  
  - Wenn Snap installiert → Option zur **Deinstallation**.  
  - Wenn Snap nicht installiert → Option zur **Installation**.  
- **Fortschrittsanzeige:** GUI-Fenster mit Statusmeldungen und automatischem Abschluss.  
- **Ergebnis:** Erfolgs- oder Fehlermeldung mit Hinweis auf Neustart.  

---

## Deinstallation
- Entfernt den **Snap Store**  
- Entfernt das **GNOME Software Plugin für Snap**  
- Entfernt **snapd** vollständig  
- Hinweis auf Neustart nach erfolgreicher Deinstallation  

---

## Installation
- Installiert **AppArmor-Komponenten**  
- Aktualisiert Paketlisten  
- Installiert **snapd**, **GNOME Software** und das Snap-Plugin  
- Erstellt Symlink `/snap`  
- Setzt PATH dauerhaft über `/etc/profile.d/snap_path.sh`  
- Aktiviert den **snapd-Dienst**  
- Richtet automatische Menü-Verlinkung über systemd ein  
- Führt sofortige Desktop-Verlinkung aus  
- Fügt den aktuellen Benutzer ggf. zur **Snap-Gruppe** hinzu  
- Hinweis auf Neustart nach erfolgreicher Installation  

---

## Hinweise
- Das Skript ist für **Debian/Ubuntu-basierte Systeme** optimiert.  
- Ein Neustart nach Installation oder Deinstallation ist erforderlich, um alle Änderungen wirksam zu machen.  
- Snap-Pakete werden in Containern ausgeführt und benötigen AppArmor für Sicherheitsrichtlinien.  

---

## Lizenz
Dieses Projekt steht unter der **MIT-Lizenz**.  
Freie Nutzung, Modifikation und Weitergabe sind erlaubt, solange der Lizenztext beibehalten wird.
```
