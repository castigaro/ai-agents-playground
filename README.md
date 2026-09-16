# ai-agents-playground

Praktische Doku und Arbeitsgrundlage für KI-gestützte Coding-Workflows mit einem lokalen Debian-basierten Server und Windows als Arbeitsrechner.

## Inhalt

- [agents.example.md](agents.example.md) - Beispiel für Leitlinien für zukünftige KI-Tools, die dieses Repo bedienen
- [docs/how-to/setup-ssh-key-windows.md](docs/how-to/setup-ssh-key-windows.md) - SSH-Key unter Windows einrichten
- [docs/how-to/setup-debian-linux-server-for-codex.md](docs/how-to/setup-debian-linux-server-for-codex.md) - Debian-Server für den `codex`-Login und Docker vorbereiten
- [docs/how-to/setup-n8n-lan.md](docs/how-to/setup-n8n-lan.md) - n8n per Docker hinter dem nginx-proxy-manager bereitstellen
- [docs/how-to/setup-n8n-mcp-codex-windows.md](docs/how-to/setup-n8n-mcp-codex-windows.md) - n8n-MCP in Codex unter Windows einrichten
- [docs/how-to/setup-context7-codex-windows.md](docs/how-to/setup-context7-codex-windows.md) - Context7 in Codex unter Windows einrichten
- [docs/how-to/setup-strato-dyndns-fritzbox.md](docs/how-to/setup-strato-dyndns-fritzbox.md) - STRATO DynDNS mit der Fritzbox einrichten
- [docs/how-to/setup-pihole-local-dns.md](docs/how-to/setup-pihole-local-dns.md) - Pi-hole lokale DNS-Einträge pflegen
- [docs/how-to/setup-edge-devtools-mcp.md](docs/how-to/setup-edge-devtools-mcp.md) - Edge als DevTools-Ziel für lokale Webseiten nutzen
- [docs/how-to/setup-github-runner-debian.md](docs/how-to/setup-github-runner-debian.md) - GitHub-Actions-Runner für spacesonar-pro als Docker-Container auf dem Server
- [docs/how-to/setup-github-runner-windows.md](docs/how-to/setup-github-runner-windows.md) - GitHub-Actions-Runner für spacesonar-pro auf dem Windows-Arbeitsrechner

## Kurzüberblick

- Auf dem Windows-Rechner wird ein eigener SSH-Key für den Codex-Zugriff verwendet.
- Der Linux-Server stellt den Login-User `codex` bereit.
- Docker-Container und Compose-Dateien werden auf dem Server verwaltet.
- Der SSH-Alias `codex-home` vereinfacht die Verbindung vom Windows-Rechner.
- n8n wird als Docker-Container unter `services/n8n` konfiguriert und per `helper-scripts/deploy-n8n.ps1` in das Home-Verzeichnis von `codex` auf dem Server ausgerollt. Mit `-Update` zieht das Skript vor dem Neustart die aktuelle `n8n:stable`-Version.
- Den HTTPS-Zugriff auf n8n übernimmt der nginx-proxy-manager des Servers; n8n selbst hängt ohne eigenen Port in dessen Docker-Netz.
- Die CI von `spacesonar-pro` läuft auf eigenen Runnern: der Linux-Job als Container unter `services/github-runner` auf dem Server (Deploy per `helper-scripts/deploy-github-runner.ps1`), Windows-Job und Release auf dem Arbeitsrechner (`helper-scripts/setup-github-runner-windows.ps1`).

## Für den Start

1. SSH-Key auf Windows einrichten oder den vorhandenen Codex-Key verwenden.
2. Den Public Key auf dem Server beim `codex`-Benutzer hinterlegen.
3. Den SSH-Alias in `~/.ssh/config` anlegen.
4. Mit `ssh codex-home` verbinden und im Projektverzeichnis arbeiten.
5. Für n8n das Deploy-Skript ausführen und anschließend die in deiner lokalen Konfiguration hinterlegte HTTPS-Adresse im Browser öffnen.
6. Für Browser-Checks Edge im Debug-Modus starten und den DevTools-MCP-Workflow nutzen.
