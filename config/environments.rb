# Environment-specific logging configuration

# Development environment
if ENV['RACK_ENV'] == 'development'
  ENV['LOG_LEVEL'] = 'debug'
  puts "Development mode: Logging level set to DEBUG"
end

# Production environment
if ENV['RACK_ENV'] == 'production'
  ENV['LOG_LEVEL'] = 'info'
  puts "Production mode: Logging level set to INFO"
end

# Test environment
if ENV['RACK_ENV'] == 'test'
  ENV['LOG_LEVEL'] = 'warn'
  puts "Test mode: Logging level set to WARN"
end

# Available log levels:
# DEBUG - Detailed information for debugging
# INFO - General information about application flow
# WARN - Warning messages for potentially harmful situations
# ERROR - Error events that might still allow the application to continue
# FATAL - Severe error events that will likely lead to application failure

# To change log level at runtime, set the LOG_LEVEL environment variable:
# export LOG_LEVEL=debug
# export LOG_LEVEL=info
# export LOG_LEVEL=warn
# export LOG_LEVEL=error
# export LOG_LEVEL=fatal 