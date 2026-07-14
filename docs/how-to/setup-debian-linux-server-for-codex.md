# Debian-basierter Linux-Server für Codex vorbereiten

Diese Anleitung richtet einen Debian-basierten Linux-Server in deinem Netzwerk so ein, dass du von einem Windows-Arbeitsrechner aus per SSH darauf zugreifen und dort Projekte, Verzeichnisse und Docker-Container verwalten kannst.

> Hinweis: Der `docker`-Gruppenzugriff ist fast so mächtig wie `root`. Verwende dafür am besten einen eigenen Benutzer nur für dieses Projekt.

## 1. Benutzer für den Zugriff anlegen

Beispiel mit dem Benutzer `codex`:

```bash
sudo adduser codex
```

Falls du den Benutzer auch für Docker nutzen willst:

```bash
sudo usermod -aG docker codex
```

Danach einmal ab- und wieder anmelden, damit die neue Gruppe aktiv wird.

## 2. Eigenen SSH-Key für Codex anlegen

Wenn du bereits einen Schlüssel wie `id_ed25519` für Git oder für den Server-Admin-Zugriff verwendest, brauchst du für Codex nicht denselben Key zu nehmen. Sinnvoller ist ein zweiter, klar benannter Schlüssel nur für Codex.

Empfohlener Name:

```text
id_ed25519_codex
```

So bleiben die Einsatzzwecke getrennt:

```text
id_ed25519         -> Git oder allgemeiner persönlicher Zugriff
id_ed25519_codex   -> nur für Login als codex auf den Server
```

Auf dem Windows-Rechner öffnest du PowerShell oder Windows Terminal und erzeugst den neuen Key:

```powershell
ssh-keygen -t ed25519 -f $env:USERPROFILE\.ssh\id_ed25519_codex -C "codex@server"
```

Falls du dir nicht sicher bist, ob `id_ed25519` schon existiert:

```powershell
Test-Path $env:USERPROFILE\.ssh\id_ed25519
```

Den öffentlichen Codex-Schlüssel anzeigen:

```powershell
type $env:USERPROFILE\.ssh\id_ed25519_codex.pub
```

Den angezeigten Inhalt dann auf dem Server in diese Datei eintragen:

```bash
/home/codex/.ssh/authorized_keys
```

Dabei müssen die Rechte stimmen:

```bash
sudo mkdir -p /home/codex/.ssh
sudo chown -R codex:codex /home/codex/.ssh
sudo chmod 700 /home/codex/.ssh
sudo chmod 600 /home/codex/.ssh/authorized_keys
```

Wenn du den Key direkt beim Verbinden angeben willst, kannst du auch:

```powershell
ssh -i $env:USERPROFILE\.ssh\id_ed25519_codex codex@<server-ip-oder-hostname>
```

## 3. SSH-Alias auf Windows einrichten

Das ist für spätere Einsaetze einfacher, weil du dann nicht jedes Mal den Key und den Host extra angeben musst.

Öffne auf dem Windows-Rechner die Datei `config` im SSH-Ordner:

```powershell
notepad $env:USERPROFILE\.ssh\config
```

Wenn die Datei noch nicht existiert, legt Notepad sie neu an. Fuege dann diesen Block ein:

```text
Host codex-home
    HostName <server-hostname-or-ip>
    User codex
    IdentityFile ~/.ssh/id_ed25519_codex
    IdentitiesOnly yes
```

Ersetze `<server-hostname-or-ip>` bei Bedarf durch den Hostnamen oder die IP-Adresse deines Servers.

Danach kannst du dich einfach so verbinden:

```powershell
ssh codex-home
```

Wenn du spaeter einen anderen Server oder Port brauchst, kannst du einfach einen weiteren `Host`-Block anlegen.

## 4. Verbindung testen

Vom Windows-Rechner aus:

```powershell
ssh codex-home
```

Wenn die Host-Abfrage erscheint, bestaetige sie mit `yes`.

Wenn das klappt, kannst du auf dem Server schon normale Befehle ausfuehren.

## 5. Projektordner anlegen

Lege einen Ordner fuer dein Projekt an, zum Beispiel unter `/opt`:

```bash
sudo mkdir -p /opt/codex-projekte/mein-projekt
sudo chown -R codex:codex /opt/codex-projekte
```

Danach als `codex` dort arbeiten:

```bash
cd /opt/codex-projekte/mein-projekt
```

## 6. Docker Compose starten

Wenn Docker und das Compose-Plugin auf dem Server bereits installiert sind und in dem Ordner eine `compose.yml` oder `docker-compose.yml` liegt:

```bash
docker compose up -d
```

Hilfreiche Folgekommandos:

```bash
docker compose ps
docker compose logs -f
docker compose down
```

## 7. Optional: Zusätzliche sudo-Rechte

Wenn du einzelne Admin-Befehle erlauben willst, nutze eine eigene `sudoers`-Datei:

```bash
sudo visudo -f /etc/sudoers.d/codex
```

Beispiel:

```text
codex ALL=(ALL) NOPASSWD: /bin/mkdir, /bin/chown, /bin/chmod, /bin/systemctl
```

> Tipp: Vergib hier nur die wirklich nötigen Befehle. Für Docker selbst reicht meist die `docker`-Gruppe.

## 8. Typischer Arbeitsablauf

1. Auf dem Windows-Arbeitsrechner per SSH auf den Server verbinden.
2. Im Projektordner neue Dateien oder Verzeichnisse anlegen.
3. `docker compose` ausführen.
4. Logs prüfen und Container neu starten, falls nötig.

## 9. Kurztest

```bash
whoami
groups
docker ps
mkdir -p /opt/codex-projekte/testverzeichnis
```

Wenn `docker ps` ohne Fehler läuft und das Verzeichnis angelegt wird, ist die Grundkonfiguration fertig.
