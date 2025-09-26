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
- **Authorization**: Pundit for role-based access control
- **Frontend**: Slim templating engine with Bootstrap 5
- **Styling**: Custom CSS for enhanced UI
- **Logging**: Ruby Logging library for comprehensive monitoring

## Requirements

- Ruby 2.6.10
- SQLite3
- Bundler gem

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd PollHub
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rake db:migrate
   rake db:seed
   ```
   
   **Note**: The database configuration uses `community_poll_hub.sqlite3` as the database file. If you encounter any database-related issues, ensure the `config/database.yml` file points to the correct database file path.

4. Configure environment (optional):
   ```bash
   # Set log level (default: info for production, debug for development)
   export LOG_LEVEL=debug
   
   # Set custom session secret (optional - auto-generated if not set)
   export SESSION_SECRET=your_secret_key_here
   ```

5. Start the server:
   ```bash
   ruby app.rb
   ```
   
   Or for development with auto-reload:
   ```bash
   bundle exec rerun 'rackup config.ru -p 4567'
   ```

6. Visit `http://localhost:4567` in your browser

## Default Test Accounts

After seeding the database with `rake db:seed`, you can log in with these pre-configured test accounts:

### Admin Account
- **Username**: `admin`
- **Email**: `admin@example.com` 
- **Password**: `AdminPassword123!`
- **Role**: Admin (full system access, user management, activity monitoring)

### Organizer Account
- **Username**: `organizer`
- **Email**: `organizer@example.com`
- **Password**: `OrganizerPass123!`
- **Role**: Organizer (can create and manage polls)

### Voter Accounts
- **Username**: `voter1`
- **Email**: `voter1@example.com`
- **Password**: `VoterPassword123!`
- **Role**: Voter (can participate in polls)

- **Username**: `voter2`
- **Email**: `voter2@example.com`
- **Password**: `VoterPassword123!`
- **Role**: Voter (can participate in polls)

**Security Note**: All passwords meet the minimum security requirements (12+ characters, uppercase, lowercase, numbers, and special characters).


## Logging Configuration

### Environment-Based Log Levels

The application automatically sets log levels based on the environment:

- **Development**: DEBUG level (detailed debugging information)
- **Production**: INFO level (general application flow)  
- **Test**: WARN level (warnings and errors only)

You can override the default log level by setting the `LOG_LEVEL` environment variable.

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

- **Pundit**: [https://github.com/varvet/pundit](https://github.com/varvet/pundit)
  - Object-oriented authorization for Ruby applications
  - Policy-based access control for different user roles

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
```bash
rspec
```

## Troubleshooting

### Common Issues

**Database errors on first run:**
```bash
# If you encounter database errors, try:
rake db:drop db:migrate db:seed
```

**Rake commands not working:**
If `rake db:migrate` or `rake db:seed` fail, common issues include:
- **Database configuration mismatch**: Ensure `config/database.yml` points to the correct database file
- **Password validation errors**: All seed passwords must be at least 12 characters and include uppercase, lowercase, numbers, and special characters
- **Missing dependencies**: Run `bundle install` first to ensure all required gems are installed

**Permission errors with SQLite:**
```bash
# Ensure the db directory is writable:
chmod 755 db/
```

**Bundle install issues:**
```bash
# If you have Ruby version conflicts:
rbenv install 2.6.10
rbenv local 2.6.10
bundle install
```

**Port already in use:**
```bash
# If port 4567 is busy, specify a different port:
ruby app.rb -p 3000
# or
bundle exec rerun 'rackup config.ru -p 3000'
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
