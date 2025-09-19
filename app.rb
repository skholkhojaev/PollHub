require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require 'slim'
require 'bcrypt'

# Load environment configuration
require_relative 'config/environments'

# Load logging configuration
require_relative 'config/logger'

# Load logging utilities
require_relative 'lib/logging_utils'

# Load models
Dir["./app/models/*.rb"].each { |file| require file }

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
  user = User.find_by(username: params[:username])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    session[:user_role] = user.role
    log_user_action(Loggers.auth, 'login_successful', { username: params[:username] })
    redirect '/'
  else
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
    role: 'voter', # Default role
    password: params[:password]
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
    current_user && current_user.role == 'admin'
  end

  def organizer?
    current_user && current_user.role == 'organizer'
  end

  def voter?
    current_user && current_user.role == 'voter'
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