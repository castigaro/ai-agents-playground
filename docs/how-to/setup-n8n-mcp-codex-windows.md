# n8n-MCP in Codex unter Windows einrichten

Diese Anleitung beschreibt die funktionierende Einrichtung, mit der Codex auf den n8n-MCP-Endpunkt zugreifen kann. Der n8n-Server selbst lauft bereits extern, und Codex verbindet sich unter Windows uber einen `supergateway`-Wrapper mit dem Streamable-HTTP-Endpunkt.

## Ergebnis

Mit der finalen Konfiguration:

- ist `n8n-mcp` in `codex mcp list` sichtbar
- ist der Server in `codex mcp get n8n-mcp` als `enabled` registriert
- lauft der Zugriff uber `npx.cmd` statt `npx`, damit Windows nicht an der PowerShell-Execution-Policy hangt

## Voraussetzungen

- Windows
- installierter Codex CLI
- Node.js mit `npx`
- Zugriff auf `%USERPROFILE%\.codex\config.toml`
- ein gueltiger n8n-MCP-Bearer-Token

## 1. Codex-Konfiguration oeffnen

Die Datei liegt hier:

```text
%USERPROFILE%\.codex\config.toml
```

## 2. n8n-MCP als `supergateway`-Wrapper eintragen

Der funktionierende Block sieht so aus:

```toml
[mcp_servers.n8n-mcp]
command = "npx.cmd"
args = [
  "-y",
  "supergateway",
  "--streamableHttp",
  "https://n8n.example.tld/mcp-server/http",
  "--header",
  "authorization:Bearer <dein-n8n-token>"
]
enabled = true
```

Wichtig:

- Der Token wird direkt im Header an `supergateway` uebergeben.
- Unter Windows ist `npx.cmd` wichtig, weil `npx.ps1` in manchen Umgebungen durch die Execution Policy blockiert wird.
- Die fruehere direkte `streamable_http`-Konfiguration fuehrte in dieser Umgebung nicht sauber zum Laden des Tools in Codex.

## 3. Alte Variante ersetzen

Wenn du vorher einen Block mit `url = "https://.../mcp-server/http"` und `bearer_token_env_var` hattest, ersetze ihn durch die `supergateway`-Variante oben.

## 4. Codex pruefen

Nach dem Neustart von Codex oder VS Code kannst du die lokale Registrierung pruefen:

```powershell
codex mcp list
codex mcp get n8n-mcp --json
```

Erwartung:

- `n8n-mcp` steht in der Liste
- `transport.type` ist `stdio`
- `command` ist `npx.cmd`

## 5. Diagnose

Wenn etwas nicht passt, helfen diese Checks:

```powershell
codex doctor
```

Und fuer die direkte Sicht auf den registrierten MCP-Server:

```powershell
codex mcp get n8n-mcp
```

## 6. Hinweise aus dem Testlauf

In diesem Setup war eine separate Windows-Umgebungsvariable fuer den Token nicht notwendig. Entscheidend war, dass der Token im `supergateway`-Header korrekt mitgegeben wird und Codex den MCP-Server ueber `npx.cmd` startet.

## 7. n8n selbst vorbereiten

Auch in n8n muss der MCP-Zugriff aktiv sein. In der gezeigten Oberflaeche findest du das unter:

```text
https://<deine-n8n-url>/settings/mcp
```

Dort ist die relevante Seite **Instance-level MCP**. Fuer die Einrichtung sind vor allem diese Schritte wichtig:

- den Instance-level-MCP-Schalter auf **Enabled** setzen
- ueber **Connection details** die Verbindungsdaten pruefen, falls du den Endpunkt oder die Authentifizierung spaeter nochmal kontrollieren willst
- auf **Enable workflows** klicken, damit Workflows fuer MCP sichtbar bzw. nutzbar werden
- sicherstellen, dass der gewuenschte Workflow in der Liste erscheint

Zum Screenshot:

- Der Eintrag **My workflow** zeigt, dass ein Workflow bereits auf Instance-Ebene erfasst ist.
- Die Spalte **Location** kann auf **Personal** stehen; das ist fuer die Sichtbarkeit hilfreich.
- Eine Beschreibung ist nicht zwingend noetig, aber sie macht die Liste spaeter leichter lesbar.

Wenn der Workflow nicht in der MCP-Liste auftaucht, lohnt es sich zuerst zu pruefen, ob er in n8n wirklich fuer MCP freigeschaltet wurde und ob der Instance-level-MCP-Schalter aktiv ist.
