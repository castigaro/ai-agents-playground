# GitHub-Actions-Runner für spacesonar-pro auf dem Debian-Server

Der Linux-Job der CI von `castigaro/spacesonar-pro` (Formatierung, Frontend-Checks, Clippy und Coverage der plattformunabhängigen Rust-Crates, Audits) läuft als self-hosted Runner in einem Docker-Container auf dem Server. Toolchain, Cargo-Registry, Node und das Arbeitsverzeichnis mit `target/` liegen in Volumes und bleiben zwischen den Läufen erhalten; nach dem ersten, kalten Lauf baut der Job inkrementell.

## Dateien im Projekt

- `services/github-runner/docker-compose.yml`
- `services/github-runner/Dockerfile` – Upstream-Image `myoung34/github-runner:ubuntu-noble` plus Build-Abhängigkeiten (`build-essential`, `cmake`, `libssl-dev`, `pkg-config`)
- `services/github-runner/entrypoint-rust.sh` – installiert `rustup` ohne Toolchain ins Home-Volume, falls es fehlt
- `services/github-runner/.env.example`
- `helper-scripts/deploy-github-runner.ps1`

## Voraussetzungen

- Der SSH-Alias `codex-home` ist eingerichtet, `codex` ist in der `docker`-Gruppe, Docker Engine mit `docker compose` läuft (siehe [Debian-Server vorbereiten](setup-debian-linux-server-for-codex.md)).
- `gh` ist auf dem Windows-Rechner angemeldet und darf das Repo verwalten (für das Registrierungstoken).
- Der Prozessor unterstützt x86-64-v3 (AVX2); die ONNX-Runtime, die ein Crate beim Build lädt, setzt das voraus. Ein Haswell-i5 genügt.
- Platz: das Arbeitsverzeichnis mit `target/` wächst auf mehrere GB.

## Warum so

- Der Runner läuft **nicht** auf GitHub-gehosteten Maschinen, weil jeder PR dort Minuten kostet; im Haus kostet er nichts und baut inkrementell.
- Das Label `spacesonar` sorgt dafür, dass nur die Jobs dieses Repos hier landen; `self-hosted`, `Linux` und `X64` fügt GitHub selbst hinzu.
- Die Registrierung liegt im Volume `runner_config` (`CONFIGURED_ACTIONS_RUNNER_FILES_DIR`), und der Container meldet sich beim Stoppen nicht ab (`DISABLE_AUTOMATIC_DEREGISTRATION=true`). Das Token wird deshalb nur beim ersten Start gebraucht; danach überlebt der Runner Neustarts von Container und Server.
- Rust kommt über `rustup toolchain install` aus der `rust-toolchain.toml` des Repos im ersten Lauf; ein Image-Update ändert daran nichts, weil `~/.rustup` und `~/.cargo` im Volume `runner_home` liegen.

## 1. Lokale Konfiguration

```text
services/github-runner/.env.example
```

nach `services/github-runner/.env` kopieren (bleibt lokal, `*.env` ist ignoriert) und `RUNNER_TOKEN` eintragen. Das Token kommt aus Settings → Actions → Runners → „New self-hosted runner" oder per

```powershell
gh api -X POST repos/castigaro/spacesonar-pro/actions/runners/registration-token --jq .token
```

Es gilt eine Stunde; abgelaufen ist es harmlos, solange die Registrierung im Volume liegt. Alternativ nimmt `ACCESS_TOKEN` ein persönliches Zugriffstoken mit Repo-Verwaltung; dann holt sich der Container Registrierungstoken selbst, das Geheimnis liegt aber dauerhaft auf dem Server.

`CARGO_BUILD_JOBS` begrenzt die parallelen `rustc`-Prozesse (Standard 4, so viele Kerne hat der Server); kleiner stellen, wenn n8n und Co. während eines Builds träge werden.

## 2. Deployment ausführen

Vom Windows-Rechner aus im Projektroot:

```powershell
.\helper-scripts\deploy-github-runner.ps1
```

Das Skript kopiert Compose-Datei, Dockerfile, Entrypoint und `.env` auf den Server, baut das Image dort und startet den Stack mit `docker compose up -d --build`. Mit `-Update` zieht es vorher das Upstream-Image neu (`docker compose build --pull`). Fehlt die `.env`, legt es sie aus der Vorlage an und bricht ab, bis das Token drinsteht.

## 3. Zielpfad auf dem Server

```text
/home/codex/ai-agents-playground/services/github-runner
```

## 4. Prüfen

- `docker compose logs -f` zeigt beim ersten Start die rustup-Installation, dann `Configuring` und `Listening for Jobs`.
- Unter https://github.com/castigaro/spacesonar-pro/settings/actions/runners steht der Runner auf „Idle".
- Der erste CI-Lauf installiert Toolchain, Node und `cargo-llvm-cov` und dauert entsprechend (Erwartung 10–20 min kalt, danach 3–5 min).

## 5. Nützliche Kommandos auf dem Server

```bash
cd /home/codex/ai-agents-playground/services/github-runner
docker compose ps
docker compose logs -f
docker compose restart
docker compose down            # Registrierung bleibt im Volume
docker compose build --pull && docker compose up -d   # Upstream-Image aktualisieren
docker system df               # Platz der Volumes
```

Ein Lauf lässt sich im Container beobachten: `docker compose exec runner bash`, Arbeitsverzeichnis `/_work/spacesonar-pro/spacesonar-pro`.

## 6. Neu registrieren oder entfernen

- Wurde der Runner bei GitHub gelöscht oder ist das Volume weg: neues Token in die `.env`, dann `docker compose down -v` (löscht **alle** Volumes, auch Toolchain und Caches) oder gezielt `docker volume rm github-runner_runner_config`, danach Deploy-Skript.
- Ganz entfernen: Runner bei GitHub unter Settings → Actions → Runners löschen, auf dem Server `docker compose down -v`.

## 7. Betrieb

- Der Runner aktualisiert sich selbst; das Image gelegentlich mit `-Update` neu bauen, damit der Start nicht jedes Mal mit einem Update beginnt.
- Ist der Server aus, bleibt der Linux-Job bei GitHub in der Warteschlange (bis zu 24 h). Rückfall auf GitHub-gehostete Runner: `gh workflow run ci.yml --ref <branch> -f hosted=true` im Repo `spacesonar-pro`.
- Solange das Repo privat ist, laufen nur eigene PRs auf dem Runner. Vor einer Veröffentlichung: Settings → Actions → „Require approval for all outside collaborators" und den Runner in eine Runner-Gruppe, die nur `main` und Tags bedient.
