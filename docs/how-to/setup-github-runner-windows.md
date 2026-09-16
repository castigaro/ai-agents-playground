# GitHub-Actions-Runner für spacesonar-pro auf dem Windows-Arbeitsrechner

Der Windows-Job der CI von `castigaro/spacesonar-pro` (Clippy über den ganzen Workspace, Tests der Host-Crates, Bindings-Diff, Release-Build mit NSIS-Installer und Smoke-Test) und der komplette Release-Workflow laufen als self-hosted Runner auf dem Arbeitsrechner, der die Toolchain ohnehin hat. Der Runner behält sein Arbeitsverzeichnis, baut also inkrementell.

## Dateien im Projekt

- `helper-scripts/setup-github-runner-windows.ps1`

## Voraussetzungen

- Auf dem PATH des angemeldeten Benutzers: `git`, `rustup`, `cargo`, `node` (24), `gh` (angemeldet, darf das Repo verwalten). Dazu Visual Studio Build Tools mit C++-Workload und WebView2 – alles, womit das Repo auch lokal gebaut wird.
- Smart App Control ist aus, sonst blockt es frisch kompilierte Binaries.
- Platz auf `D:`: `D:\actions-runner\_work` mit eigenem `target/` wächst auf mehrere GB.

## Warum so

- **Programm statt Dienst.** Der Smoke-Test startet die App mit WebView2, und ein Dienst hat keinen Desktop (Session 0). Der Runner läuft deshalb als Programm unter dem angemeldeten Benutzer, gestartet von der Aufgabenplanung bei der Anmeldung, minimiert im eigenen Konsolenfenster.
- Das Label `spacesonar` sorgt dafür, dass nur die Jobs dieses Repos hier landen; `self-hosted`, `Windows` und `X64` fügt GitHub selbst hinzu.
- Das Arbeitsverzeichnis des Runners (`D:\actions-runner\_work\spacesonar-pro`) ist vom Entwicklungs-Checkout getrennt; lokale Builds und CI-Jobs stören sich nur über die CPU.

## 1. Einrichten per Skript

In einer PowerShell (7, nicht erhöht) im Projektroot:

```powershell
.\helper-scripts\setup-github-runner-windows.ps1
```

Meldet PowerShell „Die Ausführung von Skripts ist auf diesem System deaktiviert", entweder einmalig `pwsh -ExecutionPolicy Bypass -File .\helper-scripts\setup-github-runner-windows.ps1` oder dauerhaft für den Benutzer `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` (gilt dann auch für die anderen Skripte unter `helper-scripts/`).

Das Skript

- prüft, dass die Werkzeuge auf dem PATH sind,
- lädt die aktuelle Runner-Version von `actions/runner` nach `D:\actions-runner`, falls dort noch keine liegt,
- holt per `gh api` ein Registrierungstoken und registriert den Runner mit dem Rechnernamen (klein geschrieben) und dem Label `spacesonar`,
- legt die Aufgabe „GitHub Actions Runner" an: Auslöser „Bei Anmeldung" des aktuellen Benutzers, „Nur ausführen, wenn Benutzer angemeldet ist", ohne Zeitlimit, auch im Akkubetrieb, nicht doppelt starten,
- startet die Aufgabe sofort, wenn kein Runner läuft.

Parameter: `-Repo`, `-RunnerDir`, `-RunnerName`, `-Labels`, `-Token` (wenn `gh api` das Token nicht liefern darf: aus Settings → Actions → Runners → „New self-hosted runner" kopieren), `-TaskName`.

## 2. Von Hand (falls das Skript nicht passt)

1. Settings → Actions → Runners → „New self-hosted runner" → Windows x64; die angezeigten Befehle in einer PowerShell ausführen, Ordner `D:\actions-runner`, bei `config.cmd` das Label `spacesonar` angeben. **Nicht** als Dienst einrichten (`svc install` überspringen), stattdessen `run.cmd` einmal starten und prüfen, dass GitHub „Idle" zeigt.
2. Aufgabenplanung → Aufgabe erstellen: Auslöser „Bei Anmeldung" (nur dieser Benutzer); Aktion `cmd.exe` mit den Argumenten `/c start "GitHub Actions Runner" /min "D:\actions-runner\run.cmd"`; unter „Allgemein" „Nur ausführen, wenn Benutzer angemeldet ist"; unter „Bedingungen" die Akku-Haken raus; unter „Einstellungen" „Aufgabe beenden, falls Ausführung länger als" **abwählen** und „Keine neue Instanz starten".

## 3. Prüfen

- Unter https://github.com/castigaro/spacesonar-pro/settings/actions/runners steht der Runner auf „Idle".
- In der Taskleiste liegt ein minimiertes Fenster „GitHub Actions Runner"; darin und unter `D:\actions-runner\_diag` steht das Protokoll.
- Nach Abmelden und Anmelden ist das Fenster wieder da.
- In der Aufgabenplanung zeigt „GitHub Actions Runner" → Einstellungen kein Zeitlimit; sonst dort abwählen, ein Release-Build darf länger als die Standardgrenze laufen.
- Der erste Lauf lädt Node in den Tool-Cache des Runners und baut kalt (Erwartung 8–12 min, danach 2–3 min; Release-Build und Smoke-Test in wenigen Minuten, Smoke-Budget 3 s).

## 4. Betrieb

- **Abmelden oder Standby während eines Jobs** lässt den Job scheitern (GitHub meldet nach etwa zehn Minuten ohne Verbindung „lost communication"). Nach der Anmeldung startet der Runner wieder; den Lauf bei GitHub neu starten. Bildschirm sperren ist unkritisch.
- Ist der Rechner aus, bleiben Windows-Job und Release bei GitHub in der Warteschlange (bis zu 24 h). Rückfall auf GitHub-gehostete Runner: `gh workflow run ci.yml --ref <branch> -f hosted=true` bzw. `gh workflow run release.yml --ref main -f hosted=true`.
- Der Runner aktualisiert sich selbst (`run.cmd` startet nach einem Update neu).
- Anhalten: Fenster schließen oder `Stop-ScheduledTask -TaskName "GitHub Actions Runner"`; weiter mit `Start-ScheduledTask -TaskName "GitHub Actions Runner"`.
- Der Updater-Schlüssel bleibt Secret bei GitHub und erreicht den Runner nur als Umgebungsvariable während des Release-Jobs.

## 5. Entfernen

```powershell
Unregister-ScheduledTask -TaskName "GitHub Actions Runner" -Confirm:$false
cd D:\actions-runner
.\config.cmd remove --token (gh api -X POST repos/castigaro/spacesonar-pro/actions/runners/remove-token --jq .token)
```

Danach den Ordner `D:\actions-runner` löschen.

## 6. Bevor das Repo öffentlich wird

Settings → Actions → „Require approval for all outside collaborators" einschalten und den Runner in eine Runner-Gruppe legen, die nur `main` und Tags bedient; sonst könnte ein fremder PR Code auf diesem Rechner ausführen.
