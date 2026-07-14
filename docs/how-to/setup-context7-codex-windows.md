# Context7 in Codex unter Windows einrichten

Diese Anleitung zeigt, wie du Context7 in der Codex-Umgebung in VS Code aktivierst. Der Fokus liegt auf der freien Variante: Node.js per `winget` installieren, den MCP-Server in `~/.codex/config.toml` eintragen und danach VS Code neu starten.

## Wofur das gut ist

- Context7 kann aktuelle Doku und Codebeispiele zu Bibliotheken liefern.
- Fur n8n kann das helfen, wenn du konkrete Node-, Credential- oder Workflow-Beispiele brauchst.
- Die freie Variante lauft lokal uber `npx` und braucht keinen kostenpflichtigen Plan.

## Voraussetzungen

- Windows mit `winget`
- VS Code mit Codex
- Zugriff auf die Datei `%USERPROFILE%\.codex\config.toml`

## 1. Node.js per winget installieren

Installiere die Node.js-LTS-Version mit `winget`:

```powershell
winget install -e --id OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
```

Wenn `winget` nach einem Neustart fragt, kannst du das direkt mit erledigen.

## 2. Installation pruefen

Prufe danach, ob Node.js und `npx` verfugbar sind:

```powershell
node -v
npx -v
```

Wenn beide Befehle eine Versionsnummer ausgeben, ist die Voraussetzung erfullt.

## 3. Context7 in Codex registrieren

Offne deine Codex-Konfiguration unter:

```text
%USERPROFILE%\.codex\config.toml
```

Fuge diesen Block hinzu:

```toml
[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]
```

Wenn du bereits andere MCP-Server in der Datei hast, lasst du die bestehenden Eintrage einfach stehen.

## 4. VS Code neu starten

Nach der Anpassung von `config.toml` musst du VS Code komplett neu starten, damit Codex den neuen MCP-Server einliest.

## 5. Testen

Nach dem Neustart solltest du in Codex testweise nach n8n-bezogenen Beispielen oder Doku fragen. Wenn Context7 aktiv ist, kann Codex die Beispiele aus dem Context7-Index ziehen.

## 6. Wenn es nicht auftaucht

- Prufe nochmal `node -v` und `npx -v`.
- Prufe, ob die `context7`-Sektion exakt in `~/.codex/config.toml` steht.
- Starte VS Code noch einmal komplett neu.
- Falls es dann immer noch nicht erscheint, ist meist die Codex-Integration selbst noch nicht neu geladen.
