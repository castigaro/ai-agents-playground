# STRATO DynDNS in der Fritzbox einrichten

Diese Anleitung beschreibt, wie du eine STRATO-Domain per DynDNS auf deine aktuelle öffentliche IP-Adresse aktualisierst.

## Wann das sinnvoll ist

- Wenn deine öffentliche IP sich regelmäßig ändert.
- Wenn eine Domain wie `n8n.example.tld` oder `homeassistant.example.tld` immer auf deinen Anschluss zeigen soll.
- Wenn du den CNAME oder DynDNS-Eintrag später für Let’s Encrypt oder andere Dienste nutzen willst.

## STRATO Update-URL

Der DynDNS-Update-Aufruf ist nur die Vorlage. Die Fritzbox setzt die aktuellen Werte beim Aktualisieren automatisch ein:

```text
https://dyndns.strato.com/nic/update?hostname=<domain>&myip=<ipaddr>
```

Dabei steht:

- `<domain>` für die Domain, die STRATO aktualisieren soll
- `<ipaddr>` für die aktuelle öffentliche IPv4-Adresse des Anschlusses

In das Feld der Fritzbox trägst du also die URL-Vorlage ein, nicht eine feste Domain oder IP-Adresse.

## Fritzbox-Konfiguration

In der Fritzbox unter den DynDNS-Einstellungen trägst du typischerweise ein:

- `DynDNS aktiv` einschalten
- `Update-URL` auf die STRATO-URL-Vorlage setzen
- `Domainname` auf die DynDNS-Hauptdomain setzen, zum Beispiel `example.tld`
- `Benutzername` und `Kennwort` mit den STRATO-Zugangsdaten befüllen

## Empfehlung für Subdomains

Für einzelne Dienste ist es sinnvoll, die Hostnamen als `CNAME` auf die DynDNS-Hauptdomain zeigen zu lassen:

- `n8n.example.tld -> example.tld.`
- `homeassistant.example.tld -> example.tld.`

So kannst du jeden Dienst separat später auf einen anderen Server oder Reverse Proxy umbiegen.

Genau so ist es auf deinen Screenshots zu sehen: Die Fritzbox aktualisiert die Hauptdomain per DynDNS, und die Subdomains werden in STRATO als `CNAME` darauf gelegt.

## Zertifikate

Wenn du Let’s Encrypt verwendest, muss die Domain von außen auflösbar sein. Für die erste Ausstellung und spätere Erneuerungen müssen die nötigen Ports oder DNS-Zugänge erreichbar bleiben.

Wenn du die Fritzbox-Portfreigabe nur für die Zertifikatserstellung nutzen willst, ist das ein guter Betriebsmodus: Freigabe aktivieren, Zertifikat ausstellen lassen, dann die Freigabe wieder schließen, solange du den Dienst nur intern oder über andere Wege erreichbar halten willst.

## Kontrolle

Nach dem Speichern prüfst du die Auflösung von außen, zum Beispiel über einen öffentlichen Resolver:

```text
n8n.example.tld
```

Wenn die Domain nicht wie erwartet auf deine öffentliche IP zeigt, kontrolliere:

- den STRATO-Zugang
- die Fritzbox-DynDNS-Einstellungen
- den Domainnamen in STRATO
