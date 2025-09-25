class ApplicationMailer
  def initialize
    @from = "noreply@communitypolls.com"
  end

  def mail(options = {})
    @to = options[:to]
    @subject = options[:subject]
    @body = options[:body]
    
    # In development, just log the email instead of sending
    if ENV['RACK_ENV'] == 'development' || ENV['RACK_ENV'].nil?
      require_relative '../../config/logger'
      Loggers.app.debug "=== EMAIL WOULD BE SENT ==="
      Loggers.app.debug "To: #{@to}"
      Loggers.app.debug "Subject: #{@subject}"
      Loggers.app.debug "Body: #{@body}"
      Loggers.app.debug "=========================="
    end
    
    # Return self for chaining
    self
  end
  
  def deliver_now
    # In a real application, this would send the email
    # For development, we just log it
    mail
  end
end
