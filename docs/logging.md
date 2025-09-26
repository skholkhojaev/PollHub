# Logging- und Überwachungssystem

## Überblick

Diese Anwendung implementiert ein umfassendes Logging- und Überwachungssystem mit der Ruby Logging-Bibliothek. Das System bietet konfigurierbare Log-Level, strukturiertes Logging und separate Log-Dateien für verschiedene Arten von Ereignissen.

## Funktionen

### Log-Level
- **DEBUG**: Detaillierte Informationen für das Debugging
- **INFO**: Allgemeine Informationen über den Anwendungsablauf
- **WARN**: Warnmeldungen für potenziell schädliche Situationen
- **ERROR**: Fehlerereignisse, die die Anwendung möglicherweise weiterhin funktionieren lassen
- **FATAL**: Schwerwiegende Fehlerereignisse, die wahrscheinlich zum Anwendungsausfall führen

### Log-Dateien
- `logs/application.log`: Alle Anwendungslogs
- `logs/error.log`: Nur Logs der Fehlerstufe

### Spezialisierte Logger
- `CommunityPollHub::App`: Hauptanwendungsereignisse
- `CommunityPollHub::Auth`: Authentifizierungs- und Autorisierungsereignisse
- `CommunityPollHub::Admin`: Administrative Aktionen
- `CommunityPollHub::Polls`: Umfragebezogene Operationen
- `CommunityPollHub::Users`: Benutzerverwaltungsoperationen
- `CommunityPollHub::Database`: Datenbankoperationen
- `CommunityPollHub::Security`: Sicherheitsereignisse

## Konfiguration

### Umgebungsbasierte Konfiguration

Das Logging-Level wird automatisch basierend auf der Umgebung konfiguriert:

- **Development**: DEBUG-Level
- **Production**: INFO-Level
- **Test**: WARN-Level

### Manuelle Konfiguration

Um das Log-Level zur Laufzeit zu ändern, setzen Sie die `LOG_LEVEL`-Umgebungsvariable:

```bash
export LOG_LEVEL=debug
export LOG_LEVEL=info
export LOG_LEVEL=warn
export LOG_LEVEL=error
export LOG_LEVEL=fatal
```

## Verwendung

### Basis-Logging

```ruby
# Verwendung spezialisierter Logger
Loggers.app.info("Anwendungsereignis")
Loggers.auth.info("Authentifizierungsereignis")
Loggers.admin.info("Admin-Aktion")
Loggers.polls.info("Umfrage-Operation")
Loggers.users.info("Benutzer-Operation")
Loggers.db.info("Datenbank-Operation")
Loggers.security.info("Sicherheitsereignis")
```

### Benutzeraktion-Logging

```ruby
# Protokolliere Benutzeraktionen mit Kontext
log_user_action(Loggers.app, 'action_name', { detail1: 'value1', detail2: 'value2' })
```

### Fehler-Logging

```ruby
# Protokolliere Fehler mit Kontext
log_error(Loggers.app, error, { path: request.path, method: request.request_method })
```

### Sicherheitsereignis-Logging

```ruby
# Protokolliere Sicherheitsereignisse
log_security_event(Loggers.security, 'event_type', { user: username, ip: ip_address })
```

### Erweiterte Logging-Hilfsmittel

```ruby
# Performance-Logging
LoggingUtils.log_performance(Loggers.app, 'operation_name', duration_ms, details)

# Datenbank-Operation-Logging
LoggingUtils.log_db_operation(Loggers.db, 'SELECT', 'users', 10, details)

# API-Request-Logging
LoggingUtils.log_api_request(Loggers.app, 'GET', '/polls', 200, duration_ms, current_user)

# Sicherheitsereignis-Logging mit Schweregrad
LoggingUtils.log_security_event_enhanced(Loggers.security, 'login_failed', :medium, details)

# Audit-Trail-Logging
LoggingUtils.log_audit_trail(Loggers.admin, 'user_update', user, current_user, changes)
```

## Log-Format

Jeder Log-Eintrag enthält:
- **Zeitstempel**: Wann das Ereignis aufgetreten ist
- **Log-Level**: DEBUG, INFO, WARN, ERROR oder FATAL
- **Logger-Name**: Welche Komponente das Log generiert hat
- **Nachricht**: Beschreibung des Ereignisses
- **Kontext**: Zusätzliche Details (Benutzer, IP, etc.)

Beispiel-Log-Eintrag:
```
[2024-01-15 14:30:25] INFO  CommunityPollHub::Auth: Benutzeraktion: login_successful | Benutzer: john_doe (123) | IP: 192.168.1.100 | Details: {:username=>"john_doe"}
```

## Sicherheits-Logging

Das System protokolliert automatisch:
- Anmeldeversuche (erfolgreich und fehlgeschlagen)
- Unbefugte Zugriffsversuche
- Admin-Aktionen
- Benutzerrollenänderungen
- Umfrage-Zugriffsverletzungen
- Selbstlöschungsversuche

## Performance-Überwachung

Das Logging-System kann verfolgen:
- Request-Verarbeitungszeiten
- Datenbank-Operationsleistung
- Benutzeraktionsmuster
- Systemressourcenverbrauch

## Überwachung und Alarmierung

### Log-Analyse

Verwenden Sie Standard-Unix-Tools zur Log-Analyse:

```bash
# Aktuelle Logs anzeigen
tail -f logs/application.log

# Nach Fehlern suchen
grep "ERROR" logs/application.log

# Nach Sicherheitsereignissen suchen
grep "Security Event" logs/application.log

# Log-Einträge nach Level zählen
grep -c "INFO" logs/application.log
grep -c "ERROR" logs/application.log
```

### Log-Rotation

Implementieren Sie Log-Rotation zur Verwaltung der Log-Dateigrößen:

```bash
# Beispiel-logrotate-Konfiguration
logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 root root
}
```

## Best Practices

1. **Angemessene Log-Level verwenden**: Protokollieren Sie nicht alles auf DEBUG-Level in der Produktion
2. **Kontext einschließen**: Immer relevanten Kontext einschließen (Benutzer, IP, Aktionsdetails)
3. **Sensible Daten vermeiden**: Niemals Passwörter, Token oder andere sensible Informationen protokollieren
4. **Strukturiertes Logging**: Konsistentes Format für ähnliche Ereignisse verwenden
5. **Performance**: Teure Operationen in Logging-Anweisungen vermeiden
6. **Überwachung**: Logs regelmäßig auf Muster und Probleme überprüfen

## Fehlerbehebung

### Häufige Probleme

1. **Logs erscheinen nicht**: Log-Level-Konfiguration überprüfen
2. **Berechtigungsfehler**: Schreibberechtigungen für logs-Verzeichnis sicherstellen
3. **Große Log-Dateien**: Log-Rotation implementieren
4. **Fehlender Kontext**: Überprüfen, ob Hilfsmethoden korrekt aufgerufen werden

### Debug-Modus

Um Debug-Logging temporär zu aktivieren:

```bash
export LOG_LEVEL=debug
ruby app.rb
```

## Verwendete externe Bibliotheken

- **Ruby Logging**: [https://github.com/TwP/logging](https://github.com/TwP/logging)
  - Umfassendes Logging-Framework für Ruby
  - Unterstützt mehrere Appender und Layouts
  - Konfigurierbare Log-Level und Filterung 