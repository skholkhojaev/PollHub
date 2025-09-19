# Logging and Monitoring System

## Overview

This application implements a comprehensive logging and monitoring system using the Ruby Logging library. The system provides configurable log levels, structured logging, and separate log files for different types of events.

## Features

### Log Levels
- **DEBUG**: Detailed information for debugging
- **INFO**: General information about application flow
- **WARN**: Warning messages for potentially harmful situations
- **ERROR**: Error events that might still allow the application to continue
- **FATAL**: Severe error events that will likely lead to application failure

### Log Files
- `logs/application.log`: All application logs
- `logs/error.log`: Error-level logs only

### Specialized Loggers
- `CommunityPollHub::App`: Main application events
- `CommunityPollHub::Auth`: Authentication and authorization events
- `CommunityPollHub::Admin`: Administrative actions
- `CommunityPollHub::Polls`: Poll-related operations
- `CommunityPollHub::Users`: User management operations
- `CommunityPollHub::Database`: Database operations
- `CommunityPollHub::Security`: Security events

## Configuration

### Environment-Based Configuration

The logging level is automatically configured based on the environment:

- **Development**: DEBUG level
- **Production**: INFO level
- **Test**: WARN level

### Manual Configuration

To change the log level at runtime, set the `LOG_LEVEL` environment variable:

```bash
export LOG_LEVEL=debug
export LOG_LEVEL=info
export LOG_LEVEL=warn
export LOG_LEVEL=error
export LOG_LEVEL=fatal
```

## Usage

### Basic Logging

```ruby
# Using specialized loggers
Loggers.app.info("Application event")
Loggers.auth.info("Authentication event")
Loggers.admin.info("Admin action")
Loggers.polls.info("Poll operation")
Loggers.users.info("User operation")
Loggers.db.info("Database operation")
Loggers.security.info("Security event")
```

### User Action Logging

```ruby
# Log user actions with context
log_user_action(Loggers.app, 'action_name', { detail1: 'value1', detail2: 'value2' })
```

### Error Logging

```ruby
# Log errors with context
log_error(Loggers.app, error, { path: request.path, method: request.request_method })
```

### Security Event Logging

```ruby
# Log security events
log_security_event(Loggers.security, 'event_type', { user: username, ip: ip_address })
```

### Enhanced Logging Utilities

```ruby
# Performance logging
LoggingUtils.log_performance(Loggers.app, 'operation_name', duration_ms, details)

# Database operation logging
LoggingUtils.log_db_operation(Loggers.db, 'SELECT', 'users', 10, details)

# API request logging
LoggingUtils.log_api_request(Loggers.app, 'GET', '/polls', 200, duration_ms, current_user)

# Security event logging with severity
LoggingUtils.log_security_event_enhanced(Loggers.security, 'login_failed', :medium, details)

# Audit trail logging
LoggingUtils.log_audit_trail(Loggers.admin, 'user_update', user, current_user, changes)
```

## Log Format

Each log entry includes:
- **Timestamp**: When the event occurred
- **Log Level**: DEBUG, INFO, WARN, ERROR, or FATAL
- **Logger Name**: Which component generated the log
- **Message**: Description of the event
- **Context**: Additional details (user, IP, etc.)

Example log entry:
```
[2024-01-15 14:30:25] INFO  CommunityPollHub::Auth: User Action: login_successful | User: john_doe (123) | IP: 192.168.1.100 | Details: {:username=>"john_doe"}
```

## Security Logging

The system automatically logs:
- Login attempts (successful and failed)
- Unauthorized access attempts
- Admin actions
- User role changes
- Poll access violations
- Self-deletion attempts

## Performance Monitoring

The logging system can track:
- Request processing times
- Database operation performance
- User action patterns
- System resource usage

## Monitoring and Alerting

### Log Analysis

Use standard Unix tools to analyze logs:

```bash
# View recent logs
tail -f logs/application.log

# Search for errors
grep "ERROR" logs/application.log

# Search for security events
grep "Security Event" logs/application.log

# Count log entries by level
grep -c "INFO" logs/application.log
grep -c "ERROR" logs/application.log
```

### Log Rotation

Consider implementing log rotation to manage log file sizes:

```bash
# Example logrotate configuration
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

1. **Use Appropriate Log Levels**: Don't log everything at DEBUG level in production
2. **Include Context**: Always include relevant context (user, IP, action details)
3. **Avoid Sensitive Data**: Never log passwords, tokens, or other sensitive information
4. **Structured Logging**: Use consistent format for similar events
5. **Performance**: Avoid expensive operations in logging statements
6. **Monitoring**: Regularly review logs for patterns and issues

## Troubleshooting

### Common Issues

1. **Logs not appearing**: Check log level configuration
2. **Permission errors**: Ensure write permissions on logs directory
3. **Large log files**: Implement log rotation
4. **Missing context**: Verify helper methods are being called correctly

### Debug Mode

To enable debug logging temporarily:

```bash
export LOG_LEVEL=debug
ruby app.rb
```

## External Libraries Used

- **Ruby Logging**: [https://github.com/TwP/logging](https://github.com/TwP/logging)
  - Comprehensive logging framework for Ruby
  - Supports multiple appenders and layouts
  - Configurable log levels and filtering 