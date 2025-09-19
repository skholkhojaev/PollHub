#!/usr/bin/env ruby

# Test script to verify logging system functionality

# Load the application
require_relative 'app'

puts "Testing logging system..."
puts "Log level: #{ENV['LOG_LEVEL'] || 'info'}"
puts "Environment: #{ENV['RACK_ENV'] || 'development'}"
puts ""

# Test basic logging
puts "Testing basic logging..."
Loggers.app.info("Test application log message")
Loggers.auth.info("Test authentication log message")
Loggers.admin.info("Test admin log message")
Loggers.polls.info("Test polls log message")
Loggers.users.info("Test users log message")
Loggers.db.info("Test database log message")
Loggers.security.info("Test security log message")

# Test different log levels
puts "Testing different log levels..."
Loggers.app.debug("Debug message (only visible if LOG_LEVEL=debug)")
Loggers.app.info("Info message")
Loggers.app.warn("Warning message")
Loggers.app.error("Error message")

# Test enhanced logging utilities
puts "Testing enhanced logging utilities..."
LoggingUtils.log_performance(Loggers.app, "test_operation", 150, { detail: "test" })
LoggingUtils.log_db_operation(Loggers.db, "SELECT", "users", 5, { condition: "active" })
LoggingUtils.log_system_event(Loggers.app, "test_system_event", { component: "test" })
LoggingUtils.log_business_event(Loggers.app, "test_business_event", { action: "test" })

# Test security event logging
puts "Testing security event logging..."
LoggingUtils.log_security_event_enhanced(Loggers.security, "test_security_event", :medium, {
  user: "test_user",
  ip: "127.0.0.1",
  user_agent: "test_browser"
})

puts ""
puts "Logging test completed!"
puts "Check the following files for log entries:"
puts "- logs/application.log"
puts "- logs/error.log"
puts ""
puts "You can view the logs with:"
puts "tail -f logs/application.log" 