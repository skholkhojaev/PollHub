# Logging utilities for enhanced logging capabilities

module LoggingUtils
  # Log performance metrics
  def self.log_performance(logger, operation, duration_ms, details = {})
    logger.info("Performance: #{operation} | Duration: #{duration_ms}ms | Details: #{details}")
  end

  # Log database operations
  def self.log_db_operation(logger, operation, table, record_count = nil, details = {})
    log_data = {
      operation: operation,
      table: table,
      record_count: record_count,
      details: details
    }
    logger.debug("Database: #{operation} | Table: #{table} | Records: #{record_count} | Details: #{details}")
  end

  # Log API requests
  def self.log_api_request(logger, method, path, status_code, duration_ms, user = nil)
    user_info = user ? "User: #{user.username} (#{user.id})" : "Anonymous"
    logger.info("API Request: #{method} #{path} | Status: #{status_code} | Duration: #{duration_ms}ms | #{user_info}")
  end

  # Log security events with enhanced details
  def self.log_security_event_enhanced(logger, event_type, severity, details = {})
    user_info = details[:user] || "Unknown"
    ip_address = details[:ip] || "Unknown"
    
    log_data = {
      event_type: event_type,
      severity: severity,
      user: user_info,
      ip: ip_address,
      timestamp: Time.now.iso8601,
      user_agent: details[:user_agent],
      session_id: details[:session_id],
      additional_details: details.except(:user, :ip, :user_agent, :session_id)
    }
    
    case severity
    when :low
      logger.info("Security Event (Low): #{event_type} | #{user_info} | IP: #{ip_address}")
    when :medium
      logger.warn("Security Event (Medium): #{event_type} | #{user_info} | IP: #{ip_address}")
    when :high
      logger.error("Security Event (High): #{event_type} | #{user_info} | IP: #{ip_address}")
    when :critical
      logger.fatal("Security Event (Critical): #{event_type} | #{user_info} | IP: #{ip_address}")
    end
  end

  # Log user activity with session tracking
  def self.log_user_activity(logger, activity, session_data = {})
    user_info = session_data[:user] || "Anonymous"
    session_id = session_data[:session_id] || "Unknown"
    
    log_data = {
      activity: activity,
      user: user_info,
      session_id: session_id,
      timestamp: Time.now.iso8601,
      ip_address: session_data[:ip],
      user_agent: session_data[:user_agent]
    }
    
    logger.info("User Activity: #{activity} | #{user_info} | Session: #{session_id}")
  end

  # Log system events
  def self.log_system_event(logger, event, details = {})
    log_data = {
      event: event,
      timestamp: Time.now.iso8601,
      details: details
    }
    
    logger.info("System Event: #{event} | Details: #{details}")
  end

  # Log business events
  def self.log_business_event(logger, event, business_data = {})
    log_data = {
      event: event,
      timestamp: Time.now.iso8601,
      business_data: business_data
    }
    
    logger.info("Business Event: #{event} | Data: #{business_data}")
  end

  # Log audit trail for sensitive operations
  def self.log_audit_trail(logger, operation, target, actor, changes = {})
    log_data = {
      operation: operation,
      target_type: target.class.name,
      target_id: target.id,
      actor: actor.username,
      actor_id: actor.id,
      timestamp: Time.now.iso8601,
      changes: changes
    }
    
    logger.warn("Audit Trail: #{operation} | Target: #{target.class.name}:#{target.id} | Actor: #{actor.username} | Changes: #{changes}")
  end

  # Log error with full context
  def self.log_error_with_context(logger, error, context = {})
    log_data = {
      error_message: error.message,
      error_class: error.class.name,
      backtrace: error.backtrace&.first(10),
      timestamp: Time.now.iso8601,
      context: context
    }
    
    logger.error("Error: #{error.message} | Class: #{error.class.name} | Context: #{context}")
  end

  # Log startup/shutdown events
  def self.log_lifecycle_event(logger, event, details = {})
    log_data = {
      event: event,
      timestamp: Time.now.iso8601,
      details: details
    }
    
    logger.info("Lifecycle Event: #{event} | Details: #{details}")
  end
end 