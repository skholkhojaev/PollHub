require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'slim'
require 'bcrypt'
require 'pundit'

# Load environment configuration
require_relative 'config/environments'

# Load logging configuration
require_relative 'config/logger'

# Load logging utilities
require_relative 'lib/logging_utils'

# Load models
Dir["./app/models/*.rb"].each { |file| require file }

# Load policies for Pundit authorization
Dir["./app/policies/*.rb"].each { |file| require file }

# Load mailers - commented out until needed for production email sending
# require_relative 'app/mailers/application_mailer'
# Dir["./app/mailers/*.rb"].each { |file| require file unless file.include?('application_mailer') }

# Load controllers
Dir["./app/controllers/*.rb"].each { |file| require file }

# Database configuration
set :database, { adapter: "sqlite3", database: "db/community_poll_hub.sqlite3" }

# Enable sessions for user authentication
enable :sessions
set :session_secret, ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

# Enable method override for DELETE and PATCH requests
use Rack::MethodOverride

# Set application root
set :root, File.dirname(__FILE__)
set :views, Proc.new { File.join(root, "app/views") }
set :public_folder, Proc.new { File.join(root, "public") }

# Log application startup
Loggers.app.info("Application starting up - Environment: #{ENV['RACK_ENV'] || 'development'}")

# Root route
get '/' do
  log_user_action(Loggers.app, 'visit_homepage')
  slim :index
end

# Authentication routes
get '/login' do
  log_user_action(Loggers.auth, 'visit_login_page')
  slim :login
end

post '/login' do
  # Prevent timing-based enumeration attacks by always performing password verification
  user = User.find_by(username: params[:username])
  
  if user&.authenticate(params[:password])
    session[:user_id] = user.id
    session[:user_role] = user.role
    log_user_action(Loggers.auth, 'login_successful', { username: params[:username] })
    redirect '/'
  else
    # Always perform BCrypt comparison even if user doesn't exist to prevent timing attacks
    BCrypt::Password.create('dummy_password') if user.nil?
    
    log_security_event(Loggers.security, 'login_failed', { username: params[:username], ip: request.ip })
    @error = "Invalid username or password"
    slim :login
  end
end

get '/register' do
  log_user_action(Loggers.auth, 'visit_register_page')
  slim :register
end

post '/register' do
  user = User.new(
    username: params[:username],
    email: params[:email],
    role_integer: 'voter', # Default role (enum will convert string to integer)
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  
  if user.save
    session[:user_id] = user.id
    session[:user_role] = user.role
    log_user_action(Loggers.auth, 'registration_successful', { username: params[:username], email: params[:email] })
    redirect '/'
  else
    log_user_action(Loggers.auth, 'registration_failed', { username: params[:username], email: params[:email], errors: user.errors.full_messages })
    @error = user.errors.full_messages.join(", ")
    slim :register
  end
end

get '/logout' do
  if current_user
    log_user_action(Loggers.auth, 'logout', { username: current_user.username })
  end
  session.clear
  redirect '/'
end

# Profile routes (Singular Resource)
get '/profile' do
  require_login
  @user = current_user
  log_user_action(Loggers.app, 'profile_viewed', { user: current_user.username })
  slim :'profile/show'
end

get '/profile/edit' do
  require_login
  @user = current_user
  log_user_action(Loggers.app, 'profile_edit_viewed', { user: current_user.username })
  slim :'profile/edit'
end

patch '/profile' do
  require_login
  @user = current_user
  
  # Handle different types of updates
  if params[:update_type] == 'profile'
    update_profile
  elsif params[:update_type] == 'password'
    update_password
  elsif params[:update_type] == 'email'
    update_email
  else
    @error = "Invalid update type"
    slim :'profile/edit'
  end
end

# Email confirmation route
get '/confirm_email/:token' do
  user = User.find_by(email_confirmation_token: params[:token])
  
  if user && user.email_confirmation_token_valid?
    begin
      user.confirm_email_change!
      log_user_action(Loggers.auth, 'email_confirmed', { 
        user: user.username, 
        new_email: user.email 
      })
      @success = "Your email address has been successfully updated!"
      slim :'profile/email_confirmed'
    rescue => e
      log_error(Loggers.app, e, { action: 'email_confirmation' })
      @error = "Failed to update email address"
      slim :'profile/email_confirmed'
    end
  else
    log_security_event(Loggers.security, 'invalid_email_confirmation_token', { 
      token: params[:token], 
      ip: request.ip 
    })
    @error = "Invalid or expired confirmation link"
    slim :'profile/email_confirmed'
  end
end

# Error handling
error do
  error = env['sinatra.error']
  log_error(Loggers.app, error, { path: request.path, method: request.request_method })
  "An error occurred. Please try again."
end

not_found do
  log_user_action(Loggers.app, 'page_not_found', { path: request.path, method: request.request_method })
  "Page not found."
end

# Helper methods
helpers do
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def admin?
    current_user && current_user.admin?
  end

  def organizer?
    current_user && current_user.organizer?
  end

  def voter?
    current_user && current_user.voter?
  end

  def require_login
    unless logged_in?
      log_security_event(Loggers.security, 'unauthorized_access_attempt', { path: request.path, method: request.request_method })
      redirect '/login'
    end
  end

  def require_admin
    unless admin?
      log_security_event(Loggers.security, 'admin_access_denied', { 
        user: current_user&.username, 
        path: request.path, 
        method: request.request_method 
      })
      redirect '/'
    end
  end

  def require_organizer
    unless organizer? || admin?
      log_security_event(Loggers.security, 'organizer_access_denied', { 
        user: current_user&.username, 
        path: request.path, 
        method: request.request_method 
      })
      redirect '/'
    end
  end
  
  # Pundit helper methods
  def authorize(record, query = nil)
    # Determine the policy method based on HTTP method
    case request.request_method
    when 'GET'
      if request.path_info.include?('/edit')
        query ||= 'edit?'
      elsif request.path_info.include?('/new')
        query ||= 'new?'
      else
        query ||= 'show?'
      end
    when 'POST'
      query ||= 'create?'
    when 'PATCH', 'PUT'
      query ||= 'update?'
    when 'DELETE'
      query ||= 'destroy?'
    else
      query ||= 'show?'
    end
    
    policy = policy(record)
    
    unless policy.public_send(query)
      log_security_event(Loggers.security, 'policy_authorization_denied', {
        user: current_user&.username,
        resource: record.class.name,
        action: query,
        path: request.path
      })
      halt 403, "Not authorized"
    end
    
    record
  end
  
  def policy(record)
    policy_class = policy_class_for(record)
    policy_class.new(current_user, record)
  end
  
  def policy_scope(scope)
    policy_class = policy_class_for(scope)
    policy_class::Scope.new(current_user, scope).resolve
  end
  
  private
  
  def policy_class_for(record)
    if record.is_a?(Class)
      class_name = record.name
    else
      class_name = record.class.name
    end
    "#{class_name}Policy".constantize
  end
  
  # Profile update helper methods
  def update_profile
    update_params = {
      username: params[:username]
    }
    
    if @user.update(update_params)
      log_user_action(Loggers.app, 'profile_updated', { 
        user: @user.username,
        updated_fields: ['username']
      })
      @success = "Profile updated successfully!"
      slim :'profile/show'
    else
      log_user_action(Loggers.app, 'profile_update_failed', { 
        user: @user.username,
        errors: @user.errors.full_messages 
      })
      @error = @user.errors.full_messages.join(", ")
      slim :'profile/edit'
    end
  end
  
  def update_password
    current_password = params[:current_password]
    new_password = params[:new_password]
    new_password_confirmation = params[:new_password_confirmation]
    
    # Debug logging
    Loggers.app.debug "Password change attempt for user: #{@user.username}"
    Loggers.app.debug "Current password provided: #{current_password.present?}"
    Loggers.app.debug "New password length: #{new_password&.length}"
    
    # Verify current password
    unless @user.authenticate(current_password)
      Loggers.app.debug "Current password authentication failed"
      @error = "Current password is incorrect"
      slim :'profile/edit'
      return
    end
    
    # Check password confirmation
    if new_password != new_password_confirmation
      Loggers.app.debug "Password confirmation mismatch"
      @error = "New password and confirmation do not match"
      slim :'profile/edit'
      return
    end
    
    # Update password
    @user.password = new_password
    @user.password_confirmation = new_password_confirmation
    
    Loggers.app.debug "About to save user with new password"
    if @user.save
      log_user_action(Loggers.auth, 'password_changed', { user: @user.username })
      @success = "Password updated successfully!"
      slim :'profile/show'
    else
      Loggers.app.debug "Password save failed with errors: #{@user.errors.full_messages}"
      log_user_action(Loggers.auth, 'password_change_failed', { 
        user: @user.username,
        errors: @user.errors.full_messages 
      })
      @error = @user.errors.full_messages.join(", ")
      slim :'profile/edit'
    end
  end
  
  def update_email
    new_email = params[:new_email]
    
    # Check if email is already in use
    if User.where(email: new_email).where.not(id: @user.id).exists?
      @error = "Email address is already in use"
      slim :'profile/edit'
      return
    end
    
    # Validate email format
    email_pattern = /\A[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\z/
    unless new_email.match?(email_pattern)
      @error = "Invalid email format"
      slim :'profile/edit'
      return
    end
    
    # Start email confirmation process
    ActiveRecord::Base.transaction do
      @user.new_email = new_email
      @user.generate_email_confirmation_token
      
      if @user.save
        # Send confirmation email
        confirmation_url = "#{request.base_url}/confirm_email/#{@user.email_confirmation_token}"
        
        # Log the confirmation link for development (as required by task)
        puts "\n\n" + "="*80
        puts "📧 EMAIL CONFIRMATION REQUIRED FOR USER: #{@user.username}"
        puts "="*80
        puts "To: #{new_email}"
        puts "Subject: Confirm your new email address"
        puts ""
        puts "Hello #{@user.username},"
        puts ""
        puts "You have requested to change your email address to: #{new_email}"
        puts ""
        puts "🔗 CLICK THIS LINK TO CONFIRM YOUR EMAIL CHANGE:"
        puts "#{confirmation_url}"
        puts ""
        puts "⏰ This link will expire in 24 hours."
        puts ""
        puts "⚠️  If you did not request this change, please ignore this email."
        puts "="*80
        puts "COPY AND PASTE THIS LINK IN YOUR BROWSER:"
        puts "#{confirmation_url}"
        puts "="*80
        puts "\n"
        
        # Also log to application logger  
        Loggers.app.info "🔗 EMAIL CONFIRMATION LINK: #{confirmation_url}"
        
        log_user_action(Loggers.auth, 'email_change_requested', { 
          user: @user.username,
          new_email: new_email 
        })
        
        @success = "Confirmation email sent to #{new_email}. Please check your email and click the confirmation link."
        slim :'profile/show'
      else
        @error = @user.errors.full_messages.join(", ")
        slim :'profile/edit'
      end
    end
  end
end

# Poll invitation routes for voters
get '/invitations' do
  require_login
  halt 403 unless voter?
  
  @pending_invitations = current_user.pending_invitations
  
  log_user_action(Loggers.polls, 'invitations_viewed', { 
    user: current_user.username,
    pending_count: @pending_invitations.count
  })
  slim :'invitations/index'
end

post '/invitations/:id/accept' do
  require_login
  halt 403 unless voter?
  
  invitation = current_user.poll_invitations.find(params[:id])
  
  if invitation.accept!
    log_user_action(Loggers.polls, 'invitation_accepted', { 
      poll_id: invitation.poll_id,
      poll_title: invitation.poll.title,
      voter: current_user.username
    })
    redirect '/invitations'
  else
    @error = "Failed to accept invitation"
    @pending_invitations = current_user.pending_invitations
    slim :'invitations/index'
  end
end

post '/invitations/:id/decline' do
  require_login
  halt 403 unless voter?
  
  invitation = current_user.poll_invitations.find(params[:id])
  
  if invitation.decline!
    log_user_action(Loggers.polls, 'invitation_declined', { 
      poll_id: invitation.poll_id,
      poll_title: invitation.poll.title,
      voter: current_user.username
    })
    redirect '/invitations'
  else
    @error = "Failed to decline invitation"
    @pending_invitations = current_user.pending_invitations
    slim :'invitations/index'
  end
end 