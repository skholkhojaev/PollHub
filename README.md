# Community Poll Hub

A modern platform for polls, surveys, discussions and feedback, developed using Ruby, Sinatra, and SQLite.

## Features

### User Roles

- **Admin**: Monitors system activity, manages users
- **Organizer**: Creates and manages polls
- **Voter**: Participates in polls anonymously

### Core Functionality

- **Poll Management**: Organizers can create polls with single/multiple-choice questions
- **Secure Voting**: Anonymous voting system for registered users
- **Real-time Results**: Visualize poll results with progress bars
- **User Authentication**: Secure login and registration system
- **Activity Logging**: Comprehensive logging of system activities
- **Private Polls**: Organizers can create private polls with restricted visibility
- **Discussions**: Comment on polls and engage in conversations

### Logging and Monitoring

- **Configurable Log Levels**: DEBUG, INFO, WARN, ERROR, FATAL
- **Structured Logging**: Consistent format with context (user, IP, action details)
- **Security Event Tracking**: Login attempts, unauthorized access, admin actions
- **Performance Monitoring**: Request times, database operations, user patterns
- **Audit Trail**: Complete history of sensitive operations
- **Separate Log Files**: Application logs and error logs

## Domain Model

The application is built around these core models:

- **User**: Represents users with different roles (admin, organizer, voter)
- **Poll**: A voting event with questions created by organizers
- **Question**: Can be single-choice or multiple-choice
- **Option**: Answer choices for questions
- **Vote**: Anonymous record of user votes
- **Activity**: System logs of important events

## Technical Architecture

- **Framework**: Sinatra (lightweight Ruby web framework)
- **Database**: SQLite with ActiveRecord ORM
- **Authentication**: BCrypt for secure password management
- **Frontend**: Slim templating engine with Bootstrap 5
- **Styling**: Custom CSS for enhanced UI
- **Logging**: Ruby Logging library for comprehensive monitoring

## Installation

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Set up the database:
   ```
   rake db:create
   rake db:migrate
   rake db:seed
   ```

4. Configure logging (optional):
   ```bash
   # Set log level (default: info)
   export LOG_LEVEL=debug
   ```

5. Start the server:
   ```
   ruby app.rb
   ```
or 
```
bundle exec rerun 'rackup config.ru -p 4567'
```
6. Visit `http://localhost:4567` in your browser

## Logging Configuration

### Environment-Based Log Levels

- **Development**: DEBUG level (detailed debugging information)
- **Production**: INFO level (general application flow)
- **Test**: WARN level (warnings and errors only)

### Log Files

- `logs/application.log`: All application logs
- `logs/error.log`: Error-level logs only

### Log Analysis

```bash
# View recent logs
tail -f logs/application.log

# Search for errors
grep "ERROR" logs/application.log

# Search for security events
grep "Security Event" logs/application.log
```

For detailed logging documentation, see [docs/logging.md](docs/logging.md).

## External Libraries and Documentation

### Core Dependencies

- **Sinatra**: [https://sinatrarb.com/](https://sinatrarb.com/)
  - Lightweight web framework for Ruby
  - RESTful routing and middleware support

- **ActiveRecord**: [https://guides.rubyonrails.org/active_record_basics.html](https://guides.rubyonrails.org/active_record_basics.html)
  - Object-relational mapping for database operations
  - Model associations and validations

- **BCrypt**: [https://github.com/bcrypt-ruby/bcrypt-ruby](https://github.com/bcrypt-ruby/bcrypt-ruby)
  - Secure password hashing and authentication
  - Industry-standard encryption for user passwords

- **Slim**: [http://slim-lang.com/](http://slim-lang.com/)
  - Lightweight templating engine
  - Clean, readable template syntax

### Logging and Monitoring

- **Ruby Logging**: [https://github.com/TwP/logging](https://github.com/TwP/logging)
  - Comprehensive logging framework for Ruby
  - Multiple appenders, layouts, and log levels
  - Configurable filtering and formatting

### Development Tools

- **Rake**: [https://github.com/ruby/rake](https://github.com/ruby/rake)
  - Task automation and build tool
  - Database migrations and seeding

- **RSpec**: [https://rspec.info/](https://rspec.info/)
  - Behavior-driven development framework
  - Testing framework for Ruby

- **Rack Test**: [https://github.com/rack-test/rack-test](https://github.com/rack-test/rack-test)
  - Testing framework for Rack-based applications
  - HTTP request simulation for testing

## Development Guidelines

### Code Conventions

- Follow Ruby style guidelines
- Use meaningful variable and method names
- Document complex methods
- Include appropriate logging statements

### Logging Best Practices

1. Use appropriate log levels for different environments
2. Include relevant context (user, IP, action details)
3. Avoid logging sensitive information
4. Use structured logging for consistency
5. Monitor log file sizes and implement rotation

### Database Schema

The database design follows best practices:
- Foreign key constraints for relationships
- Indexes for faster queries
- Appropriate data types for each column

## Testing

Run the test suite with:
```
rspec
```

## Monitoring and Maintenance

### Log Rotation

Consider implementing log rotation to manage file sizes:

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

### Security Monitoring

The application automatically logs:
- Login attempts and failures
- Unauthorized access attempts
- Admin actions and user management
- Poll access violations
- Security-related events

## License

MIT
