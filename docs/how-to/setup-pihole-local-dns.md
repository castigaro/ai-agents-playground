# Pi-hole lokale DNS-Einträge pflegen

Diese Anleitung beschreibt, wie du in Pi-hole lokale DNS-Einträge für interne Dienste setzt.

## Wann das sinnvoll ist

- Wenn du Dienste im LAN über hübsche Hostnamen aufrufen willst.
- Wenn du im Browser statt einer IP lieber `n8n.example.tld` oder `homeassistant.example.tld` nutzt.
- Wenn ein lokaler Name auf deinen Server zeigen soll, auch wenn der öffentliche DNS-Eintrag anders gesetzt ist.

## Beispiel

Für n8n legst du einen lokalen Eintrag an:

```text
n8n.example.tld -> 192.0.2.10
```

So lösen Geräte im Heimnetz die Domain direkt auf deinen Server auf.

## Wichtiger Hinweis

Ein Pi-hole-Eintrag ersetzt keinen öffentlichen DNS-Record. Für Let’s Encrypt braucht die Domain zusätzlich von außen auflösbar zu sein.

## Typische Anwendung

- `homeassistant.example.tld -> 192.0.2.11`
- `n8n.example.tld -> 192.0.2.10`

## Pflege

Wenn sich die IP eines Servers ändert, aktualisiere den Eintrag in Pi-hole.

## Hinweis zur Weboberfläche

Pi-hole selbst sollte über seinen eigenen Verwaltungszugang erreichbar bleiben. In deinem Setup läuft das getrennt von den Diensten, die du darüber auflöst.
