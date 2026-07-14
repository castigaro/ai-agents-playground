# n8n mit Reverse Proxy im lokalen Netzwerk bereitstellen

Diese Einrichtung lauft als Docker-Compose-Stack im Home-Verzeichnis von `codex` auf dem Server. n8n selbst lauft intern auf Port `5678`, und Caddy ubernimmt den externen Zugriff per HTTPS unter einer eigenen Domain wie `https://n8n.example.tld`.

## Dateien im Projekt

- `services/n8n/docker-compose.yml`
- `services/n8n/Caddyfile`
- `services/n8n/.env.example`
- `services/n8n/local-files/`
- `scripts/deploy-n8n.ps1`

## Voraussetzungen

- Der SSH-Alias `codex-home` ist auf dem Windows-Rechner eingerichtet.
- Der Server ist per `ssh codex-home` erreichbar.
- Der Benutzer `codex` existiert auf dem Server.
- `codex` ist Mitglied der `docker`-Gruppe.
- Auf dem Server ist Docker Engine mit dem `docker compose`-Plugin verfugbar.
- Die gewunschte Domain zeigt auf deinen Server.
- Pi-hole lauft separat auf `8880` und wird nicht verandert.
- Port `80` ist fur Let's Encrypt erreichbar.
- Port `443` ist auf dem Server frei.

## Warum diese Variante sinnvoll ist

Pi-hole bleibt auf seinem eigenen Verwaltungsport erreichbar. Caddy nutzt `80` fur die ACME-Prufung und `443` fur den HTTPS-Zugriff auf n8n. Fur Let's Encrypt ist HTTP-01 uber Port `80` der Standardweg; alternativ gibt es TLS-ALPN-01 uber `443`.

## 1. Lokale Konfiguration prufen

Die Vorlage fur die Laufzeitwerte liegt hier:

```text
services/n8n/.env.example
```

Kopiere die Vorlage vor dem Start nach `services/n8n/.env` und trage dort deine echten Werte ein. Die `.env` bleibt lokal und wird nicht mitkommittiert.

Fur diese Variante sind vor allem diese Werte relevant:

- `N8N_DOMAIN`
- `SSL_EMAIL`

Wenn du spater eine andere Subdomain nutzt, musst du nur `N8N_DOMAIN` und den DNS-Eintrag anpassen.

## 2. Verknupfte How-tos

- [STRATO DynDNS einrichten](setup-strato-dyndns-fritzbox.md)
- [Pi-hole lokale DNS-Eintrage pflegen](setup-pihole-local-dns.md)

## 3. Deployment ausfuhren

Vom Windows-Rechner aus im Projektroot:

```powershell
.\scripts\deploy-n8n.ps1
```

Wenn du vor dem Neustart die aktuellste `n8n:stable`-Version ziehen willst, nutze:

```powershell
.\scripts\deploy-n8n.ps1 -Update
```

Das Skript:

- legt lokal eine `.env` aus der Vorlage an, falls sie fehlt
- synchronisiert `docker-compose.yml`, `Caddyfile` und `.env` auf den Server
- erstellt auf dem Server den Ordner `local-files`
- startet den Stack mit `docker compose up -d`
- zieht mit `-Update` vorher gezielt das `n8n`-Image per `docker compose pull n8n`

## 4. Zielpfad auf dem Server

Die Dateien landen auf dem Server unter:

```text
/home/codex/ai-agents-playground/services/n8n
```

## 5. Browserzugriff

Nach erfolgreicher Zertifikatsausstellung rufst du n8n uber HTTPS auf:

```text
https://n8n.example.tld
```

## 6. Nutzliche Kommandos auf dem Server

```bash
cd /home/codex/ai-agents-playground/services/n8n
docker compose ps
docker compose logs -f
docker compose down
docker compose pull
docker compose up -d
```

## 7. `local-files`

n8n bindet den Ordner `services/n8n/local-files` als `/files` in den Container ein. Das ist sinnvoll, wenn du Dateien zwischen Host und n8n austauschen mochtest.

## 8. Erster Start

Beim ersten Offnen von n8n im Browser legst du die Benutzerkonfiguration direkt in der Weboberflache an.

## 9. Update-Hinweis

Wenn du die Compose-Datei, das Caddy-Setup oder die `.env` anderst, fuhre das Deploy-Skript erneut aus. Danach kannst du fur spatere Updates auf dem Server den offiziellen Flow `docker compose pull`, `docker compose down`, `docker compose up -d` verwenden.

Wenn du nur die n8n-Version auf die aktuelle `stable`-Variante heben mochtest, reicht auch:

```powershell
.\scripts\deploy-n8n.ps1 -Update
```
