get '/admin' do
  # Policy-based authorization as required by task
  require_admin
  
  log_user_action(Loggers.admin, 'admin_dashboard_accessed')
  @user_count = User.count
  @poll_count = Poll.count
  @vote_count = Vote.count
  @recent_activities = Activity.latest.limit(10)
  slim :'admin/dashboard'
end

get '/admin/users' do
  # Policy-based authorization for user management
  require_admin
  
  log_user_action(Loggers.admin, 'admin_users_list_accessed')
  @users = policy_scope(User)
  slim :'admin/users'
end

get '/admin/users/:id/edit' do
  @user = User.find(params[:id])
  # Policy-based authorization for editing user details
  authorize(@user)
  
  log_user_action(Loggers.admin, 'admin_user_edit_accessed', { target_user_id: params[:id], target_username: @user.username })
  slim :'admin/edit_user'
end

patch '/admin/users/:id' do
  @user = User.find(params[:id])
  # Policy-based authorization for updating users
  authorize(@user)
  
  # Don't update password if blank
  update_params = {
    username: params[:username],
    email: params[:email],
    role_integer: params[:role_integer]
  }
  
  # Only update password if provided
  if params[:password] && !params[:password].strip.empty?
    update_params[:password] = params[:password]
  end
  
  if @user.update(update_params)
    log_user_action(Loggers.admin, 'admin_user_updated', { 
      target_user_id: params[:id], 
      target_username: @user.username,
      updated_fields: update_params.keys,
      role_changed: @user.role_previously_changed?,
      password_updated: update_params.key?(:password)
    })
    redirect '/admin/users'
  else
    log_user_action(Loggers.admin, 'admin_user_update_failed', { 
      target_user_id: params[:id], 
      target_username: @user.username,
      errors: @user.errors.full_messages 
    })
    @error = @user.errors.full_messages.join(", ")
    slim :'admin/edit_user'
  end
end

delete '/admin/users/:id' do
  @user = User.find(params[:id])
  # Policy-based authorization for deleting users (prevents self-deletion automatically)
  authorize(@user)
  
  # Additional check for self-deletion (policy should handle this, but double-check)
  if @user.id == current_user.id
    log_security_event(Loggers.security, 'admin_self_deletion_attempt', { 
      admin_user: current_user.username,
      target_user: @user.username 
    })
    @error = "You cannot delete your own account"
    redirect '/admin/users'
    return
  end
  
  username = @user.username
  @user.destroy
  log_user_action(Loggers.admin, 'admin_user_deleted', { 
    target_user_id: params[:id], 
    target_username: username,
    deleted_by: current_user.username 
  })
  redirect '/admin/users'
end

get '/admin/activities' do
  require_admin
  log_user_action(Loggers.admin, 'admin_activities_accessed')
  @activities = Activity.latest.limit(50)
  slim :'admin/activities'
end 