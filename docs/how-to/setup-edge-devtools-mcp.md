# Edge DevTools MCP für lokale Webseiten

Diese Anleitung beschreibt, wie du Microsoft Edge als Debug-Ziel für einen MCP-fähigen Coding-Agenten einrichtest. Ziel ist, lokale oder interne Webseiten wie eine n8n-Instanz direkt im Browser untersuchen und bedienen zu können, ohne Chrome vorauszusetzen.

## Warum Edge statt Chrome

- Microsoft Edge unterstützt die Microsoft Edge DevTools Protocol über Remote Debugging.
- Der Chrome DevTools MCP Server kann über den DevTools-Protocol-Zugriff mit einem laufenden Browser arbeiten.
- Für diese Anleitung bleibt Edge der Zielbrowser, damit auf Windows kein Chrome nötig ist.

## Voraussetzungen

- Windows mit installiertem Microsoft Edge
- Ein MCP-fähiger Client wie Codex CLI
- Node.js mit `npx`

## 1. Edge im Debug-Modus starten

Starte Edge mit einem separaten Benutzerprofil und einem Remote-Debugging-Port:

```powershell
.\helper-scripts\start-edge-devtools.ps1 -Url https://n8n.example.tld
```

Das Skript startet Edge mit:

- `--remote-debugging-port=9222`
- einem eigenen Profil unter `%LOCALAPPDATA%\Edge-MCP`
- der gewünschten Ziel-URL

Wenn du eine andere Seite prüfen willst, kannst du die URL einfach überschreiben.

## 2. MCP-Server registrieren

Für Codex CLI kannst du den Chrome DevTools MCP Server einhängen:

```powershell
codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest --browserUrl http://127.0.0.1:9222
```

Der Name bleibt `chrome-devtools`, auch wenn du Edge als Browser verwendest. Entscheidend ist der DevTools-Protocol-Zugriff auf den laufenden Browser über `http://127.0.0.1:9222`.

## 3. Verbindung prüfen

Wenn Edge mit Debug-Port läuft, sollte der lokale Debug-Endpoint erreichbar sein:

```text
http://127.0.0.1:9222/json/list
```

Wenn dort eine JSON-Liste mit Tabs erscheint, ist der Browser für MCP erreichbar.

## 4. Typischer Ablauf für lokale Seiten

1. Edge mit dem Debug-Skript starten.
2. Die gewünschte Seite öffnen, zum Beispiel `https://n8n.example.tld`.
3. Den MCP-fähigen Agenten auf den Browser ansetzen.
4. Mit dem Agenten DOM, Formularfelder, Logs oder Buttons prüfen.

## 5. Wichtiger Hinweis

Der Debug-Port ist mächtig. Verwende dafür ein separates Profil und lasse ihn nicht dauerhaft offen, wenn du ihn nicht brauchst.

## 6. Optional: In das Projekt einhängen

Wenn du diese Anleitung im Projekt startest, kann ein späterer Agent die Seite direkt prüfen und zum Beispiel den n8n-Owner-Account über die Weboberfläche anlegen.
