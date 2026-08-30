# n8n hinter dem nginx-proxy-manager bereitstellen

Diese Einrichtung läuft als Docker-Compose-Stack im Home-Verzeichnis von `codex` auf dem Server. n8n selbst läuft intern auf Port `5678` und veröffentlicht keinen eigenen Port. Den HTTPS-Zugriff unter einer Domain wie `https://n8n.example.tld` übernimmt der bereits vorhandene nginx-proxy-manager, der auf dem Server die Ports `80` und `443` bedient.

## Dateien im Projekt

- `services/n8n/docker-compose.yml`
- `services/n8n/.env.example`
- `services/n8n/local-files/`
- `helper-scripts/deploy-n8n.ps1`

## Voraussetzungen

- Der SSH-Alias `codex-home` ist auf dem Windows-Rechner eingerichtet.
- Der Server ist per `ssh codex-home` erreichbar.
- Der Benutzer `codex` existiert auf dem Server und ist Mitglied der `docker`-Gruppe.
- Auf dem Server ist Docker Engine mit dem `docker compose`-Plugin verfügbar.
- Der nginx-proxy-manager läuft auf dem Server; sein Docker-Netz ist in der `.env` als `PROXY_NETWORK` hinterlegt (Standard: `ngnx-proxy-manager_default`).
- Die gewünschte Domain zeigt intern per Pi-hole auf den Server und öffentlich auf die eigene Leitung, damit Let's Encrypt die HTTP-01-Prüfung über Port `80` durchführen kann.

## Warum diese Variante

Auf dem Server kann nur ein Dienst Port `443` belegen. Da der nginx-proxy-manager dort bereits andere Hosts bedient, bringt der n8n-Stack keinen eigenen Reverse Proxy mehr mit. n8n hängt stattdessen im Netz des Proxys und ist dort unter dem Hostnamen `n8n` erreichbar.

## 1. Lokale Konfiguration prüfen

Die Vorlage für die Laufzeitwerte liegt hier:

```text
services/n8n/.env.example
```

Kopiere die Vorlage vor dem Start nach `services/n8n/.env` und trage dort deine echten Werte ein. Die `.env` bleibt lokal und wird nicht mitkommittiert.

Relevant sind vor allem:

- `N8N_DOMAIN`
- `N8N_EDITOR_BASE_URL` und `N8N_WEBHOOK_URL`
- `PROXY_NETWORK`

Bei einer anderen Subdomain werden diese Werte, der DNS-Eintrag und der Proxy-Host im nginx-proxy-manager angepasst.

## 2. Verknüpfte How-tos

- [STRATO DynDNS einrichten](setup-strato-dyndns-fritzbox.md)
- [Pi-hole lokale DNS-Einträge pflegen](setup-pihole-local-dns.md)

## 3. Deployment ausführen

Vom Windows-Rechner aus im Projektroot:

```powershell
.\helper-scripts\deploy-n8n.ps1
```

Wenn vor dem Neustart die aktuellste `n8n:stable`-Version gezogen werden soll:

```powershell
.\helper-scripts\deploy-n8n.ps1 -Update
```

Das Skript:

- legt lokal eine `.env` aus der Vorlage an, falls sie fehlt
- synchronisiert `docker-compose.yml` und `.env` auf den Server
- erstellt auf dem Server den Ordner `local-files`
- startet den Stack mit `docker compose up -d`
- zieht mit `-Update` vorher gezielt das `n8n`-Image per `docker compose pull n8n`

## 4. Zielpfad auf dem Server

```text
/home/codex/ai-agents-playground/services/n8n
```

## 5. Proxy-Host im nginx-proxy-manager anlegen

In der Oberfläche des Proxys unter „Proxy Hosts“ einen Host anlegen:

- Domain Names: die Domain aus `N8N_DOMAIN`
- Scheme: `http`, Forward Hostname: `n8n`, Forward Port: `5678`
- Websockets Support: an (sonst bleibt der n8n-Editor ohne Live-Verbindung)
- Block Common Exploits: an
- Access List: `intern only`, solange nur der Zugriff aus dem eigenen Netz gewünscht ist
- SSL: „Request a new Certificate“ mit Let's Encrypt, dazu Force SSL und HTTP/2

Sollen Webhooks von außen ankommen, kommen unter „Custom Locations“ zwei Einträge dazu: `/webhook` und `/webhook-test`, jeweils auf `n8n:5678`, im Feld „Advanced“ mit `allow all;`. Diese Zeile steht in der erzeugten Konfiguration vor den Regeln der Access-List und hebt sie damit für genau diese Pfade auf.

## 6. Browserzugriff

```text
https://n8n.example.tld
```

## 7. Nützliche Kommandos auf dem Server

```bash
cd /home/codex/ai-agents-playground/services/n8n
docker compose ps
docker compose logs -f
docker compose down
docker compose pull
docker compose up -d
```

## 8. `local-files`

n8n bindet den Ordner `services/n8n/local-files` als `/files` in den Container ein. Das ist sinnvoll, wenn Dateien zwischen Host und n8n ausgetauscht werden sollen.

## 9. Erster Start

Beim ersten Öffnen von n8n im Browser wird die Benutzerkonfiguration direkt in der Weboberfläche angelegt.

## 10. Update-Hinweis

Nach Änderungen an der Compose-Datei oder der `.env` das Deploy-Skript erneut ausführen. Für spätere Versionsupdates reicht auf dem Server der Flow `docker compose pull`, `docker compose down`, `docker compose up -d` oder das Skript mit `-Update`.

## 11. Externe Webhooks

Der Stack veröffentlicht selbst keinen Port mehr. Für Webhooks von außen (etwa Telegram) bedient der nginx-proxy-manager einen zweiten Port: In seinem Compose kommt neben `443:443` das Mapping `8443:443` dazu, im Router zeigt die Freigabe für 8443 auf den Server. Telegram akzeptiert nur die Ports 443, 80, 88 und 8443.

Damit n8n seine Webhook-Adressen mit diesem Port bildet, steht in der `.env` (bis n8n 2.35 hieß die Variable `WEBHOOK_URL`):

```text
N8N_WEBHOOK_URL=https://n8n.example.tld:8443/
```

Zusammen mit den beiden Custom Locations ist von außen nur `/webhook` und `/webhook-test` erreichbar; jeder andere Pfad läuft über 8443 in die Access-List und wird abgewiesen. Nach einer Änderung an `N8N_WEBHOOK_URL` müssen aktive Workflows einmal neu aktiviert werden, damit die Adresse beim Dienst neu registriert wird – ein Neustart des Containers erledigt das.
