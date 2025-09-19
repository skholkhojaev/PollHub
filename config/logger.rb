require 'logging'

# Create logs directory if it doesn't exist
Dir.mkdir('logs') unless Dir.exist?('logs')

# Configure the logging system
Logging.init

# Create a logger for the application
logger = Logging.logger['CommunityPollHub']

# Set the log level based on environment
log_level = ENV.fetch('LOG_LEVEL', 'info').upcase.to_sym
logger.level = log_level

# Create a file appender for all logs
file_appender = Logging.appenders.file(
  'logs/application.log',
  layout: Logging.layouts.pattern(
    pattern: '[%d] %-5l %c{2}: %m\n',
    date_pattern: '%Y-%m-%d %H:%M:%S'
  ),
  truncate: false
)

# Create a file appender for errors only
error_appender = Logging.appenders.file(
  'logs/error.log',
  layout: Logging.layouts.pattern(
    pattern: '[%d] %-5l %c{2}: %m\n',
    date_pattern: '%Y-%m-%d %H:%M:%S'
  ),
  truncate: false
)

# Add appenders to the logger
logger.add_appenders(file_appender, error_appender)

# In development, also log to console
if ENV['RACK_ENV'] == 'development'
  console_appender = Logging.appenders.stdout(
    layout: Logging.layouts.pattern(
      pattern: '[%d] %-5l %c{2}: %m\n',
      date_pattern: '%Y-%m-%d %H:%M:%S'
    )
  )
  logger.add_appenders(console_appender)
end

# Create specialized loggers for different components
module Loggers
  # Main application logger
  def self.app
    Logging.logger['CommunityPollHub::App']
  end

  # Authentication logger
  def self.auth
    Logging.logger['CommunityPollHub::Auth']
  end

  # Admin actions logger
  def self.admin
    Logging.logger['CommunityPollHub::Admin']
  end

  # Poll operations logger
  def self.polls
    Logging.logger['CommunityPollHub::Polls']
  end

  # User operations logger
  def self.users
    Logging.logger['CommunityPollHub::Users']
  end

  # Database operations logger
  def self.db
    Logging.logger['CommunityPollHub::Database']
  end

  # Security logger
  def self.security
    Logging.logger['CommunityPollHub::Security']
  end
end

# Helper method to log user actions with context
def log_user_action(logger, action, details = {})
  user_info = current_user ? "User: #{current_user.username} (#{current_user.id})" : "Anonymous"
  ip_address = request.ip rescue "unknown"
  user_agent = request.user_agent rescue "unknown"
  
  log_data = {
    action: action,
    user: user_info,
    ip: ip_address,
    user_agent: user_agent,
    timestamp: Time.now.iso8601,
    details: details
  }
  
  logger.info("User Action: #{action} | #{user_info} | IP: #{ip_address} | Details: #{details}")
end

# Helper method to log errors with context
def log_error(logger, error, context = {})
  user_info = current_user ? "User: #{current_user.username} (#{current_user.id})" : "Anonymous"
  ip_address = request.ip rescue "unknown"
  
  log_data = {
    error: error.message,
    error_class: error.class.name,
    backtrace: error.backtrace&.first(5),
    user: user_info,
    ip: ip_address,
    timestamp: Time.now.iso8601,
    context: context
  }
  
  logger.error("Error: #{error.message} | #{user_info} | IP: #{ip_address} | Context: #{context}")
end

# Helper method to log security events
def log_security_event(logger, event, details = {})
  user_info = current_user ? "User: #{current_user.username} (#{current_user.id})" : "Anonymous"
  ip_address = request.ip rescue "unknown"
  
  log_data = {
    event: event,
    user: user_info,
    ip: ip_address,
    timestamp: Time.now.iso8601,
    details: details
  }
  
  logger.warn("Security Event: #{event} | #{user_info} | IP: #{ip_address} | Details: #{details}")
end 