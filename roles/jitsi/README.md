# Jitsi(optimierte Config)
Hier sind einige Optimierungen zusammengefasst, die über die Jitsi-Konfiguration getroffen werden.
Die Konfigurationsdateien liegen unter:
```bash
~/.jitsi-meet-cfg/jvb/
```
und werden als Volume via Docker-Compose eingebunden.

## Datenschutz
### Externe Verbindungen zu gravatar.com und Co. unterbinden

Verbindung zu externen Drittanbietern unterbinden.

```bash
disableThirdPartyRequests: true,
```
Danach sind die Third-Party-Requests deaktiviert. Davon nicht betroffen sind die Einstellungen der STUN- und TURN-Server.

### Logging
Standardmäßig wird Jitsi Meet mit dem Logging-Level INFO ausgeliefert. In diesem Modus erfasst die Videobridge die IP-Adressen der Teilnehmer. Da wir diese Informationen nicht erfassen und speichern möchten, haben wir das Logging-Level auf WARNING reduziert:

```bash
nano ~/.jitsi-meet-cfg/jvb/logging.properties
```

```bash
.level=WARNING
```


## Performance Optimierung
In der config.js-Datei:

### Festlegen der Standardsprache auf Deutsch

```bash
defaultLanguage: 'de',
```
### Reduzierung der Auflösung von 720 auf 480

```bash
resolution: 480,

constraints: { 
   video: {  
      aspectRatio: 16 / 9,   
      height: {    
         ideal: 480,   
         max: 480,    
         min: 240     
      }      
   }     
}, 
```

### Limitierung der übertragenen Video-Feeds

```bash
channelLastN: 4,
```

Nur die Videodaten bzw. Streams der letzten vier aktiven Sprecher wird übermittelt. Alle anderen Teilnehmer werden sozusagen »eingefroren«, bis sie wieder sprechen

### Enable Layer Suspension

```bash
enableLayerSuspension: true,
```
Der Client (ab Chrome 69) sendet nur jene Streams, die zu einem bestimmten Zeitpunkt angesehen werden, wodurch der CPU- und Bandbreitenverbrauch sowohl auf der Client- als auch auf der Server-Seite reduziert und gleichzeitig die Videoqualität verbessert wird.

### Videokonferenz nur mit Audio starten

```bash
startAudioOnly: true,
```
Video kann dann bei Bedarf aktiviert werden. Gerade wenn viele Teilnehmer einen Konferenzraum gleichzeitig betreten, sorgt das für eine deutliche Entlastung.


### Deaktivierung der blauen Audio-Dots beim Speaker

```bash
startAudioOnly: true,
```
Reduziert die CPU-Auslastung bei den Clients.