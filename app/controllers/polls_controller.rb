get '/polls' do
  require_login
  log_user_action(Loggers.polls, 'polls_list_accessed')
  
  # Use the new accessible_polls method from User model
  @polls = current_user.accessible_polls
  
  slim :'polls/index'
end

get '/polls/new' do
  require_organizer
  log_user_action(Loggers.polls, 'poll_creation_form_accessed')
  slim :'polls/new'
end

post '/polls' do
  require_organizer
  
  # Handle private flag
  private_poll = params[:private] == "1"
  
  @poll = Poll.new(
    title: params[:title],
    description: params[:description],
    start_date: params[:start_date],
    end_date: params[:end_date],
    status: 'draft',
    organizer_id: current_user.id,
    private: private_poll
  )
  
  if @poll.save
    log_user_action(Loggers.polls, 'poll_created', { 
      poll_id: @poll.id, 
      title: @poll.title, 
      private: private_poll,
      organizer: current_user.username 
    })
    redirect "/polls/#{@poll.id}/questions/new"
  else
    log_user_action(Loggers.polls, 'poll_creation_failed', { 
      title: params[:title], 
      errors: @poll.errors.full_messages 
    })
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/new'
  end
end

get '/polls/:id' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Use the new access control method
  unless @poll.user_has_access?(current_user)
    log_security_event(Loggers.security, 'unauthorized_poll_access_attempt', { 
      poll_id: params[:id], 
      user: current_user.username 
    })
    halt 403, "You don't have permission to view this poll"
  end
  
  log_user_action(Loggers.polls, 'poll_viewed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  @questions = @poll.questions.includes(:options)
  slim :'polls/show'
end

get '/polls/:id/edit' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  log_user_action(Loggers.polls, 'poll_edit_form_accessed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  slim :'polls/edit'
end

patch '/polls/:id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  # Handle private flag
  private_poll = params[:private] == "1"
  
  if @poll.update(
    title: params[:title],
    description: params[:description],
    start_date: params[:start_date],
    end_date: params[:end_date],
    status: params[:status],
    private: private_poll
  )
    log_user_action(Loggers.polls, 'poll_updated', { 
      poll_id: params[:id], 
      poll_title: @poll.title,
      updated_fields: ['title', 'description', 'start_date', 'end_date', 'status', 'private'],
      private_changed: @poll.private_previously_changed?,
      status_changed: @poll.status_previously_changed?
    })
    redirect "/polls/#{@poll.id}"
  else
    log_user_action(Loggers.polls, 'poll_update_failed', { 
      poll_id: params[:id], 
      errors: @poll.errors.full_messages 
    })
    @error = @poll.errors.full_messages.join(", ")
    slim :'polls/edit'
  end
end

delete '/polls/:id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  poll_title = @poll.title
  @poll.destroy
  log_user_action(Loggers.polls, 'poll_deleted', { 
    poll_id: params[:id], 
    poll_title: poll_title,
    deleted_by: current_user.username 
  })
  redirect '/polls'
end

get '/polls/:id/results' do
  require_login
  @poll = Poll.find(params[:id])
  
  # Use the new access control method
  unless @poll.user_has_access?(current_user)
    log_security_event(Loggers.security, 'unauthorized_poll_results_access_attempt', { 
      poll_id: params[:id], 
      user: current_user.username 
    })
    halt 403, "You don't have permission to view this poll's results"
  end
  
  log_user_action(Loggers.polls, 'poll_results_viewed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  @questions = @poll.questions.includes(:options)
  slim :'polls/results'
end

post '/polls/:id/activate' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'active')
  log_user_action(Loggers.polls, 'poll_activated', { 
    poll_id: params[:id], 
    poll_title: @poll.title,
    activated_by: current_user.username 
  })
  redirect "/polls/#{@poll.id}"
end

post '/polls/:id/close' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @poll.update(status: 'closed')
  log_user_action(Loggers.polls, 'poll_closed', { 
    poll_id: params[:id], 
    poll_title: @poll.title,
    closed_by: current_user.username 
  })
  redirect "/polls/#{@poll.id}"
end

# New routes for managing poll invitations
get '/polls/:id/invitations' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  halt 400, "This feature is only available for private polls" unless @poll.private?
  
  @invitations = @poll.poll_invitations.includes(:voter, :invited_by).order(:created_at)
  @available_voters = User.voters.where.not(id: @poll.poll_invitations.pluck(:voter_id))
  
  log_user_action(Loggers.polls, 'poll_invitations_viewed', { 
    poll_id: params[:id], 
    poll_title: @poll.title 
  })
  slim :'polls/invitations'
end

post '/polls/:id/invitations' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  halt 400, "This feature is only available for private polls" unless @poll.private?
  
  voter = User.find(params[:voter_id])
  halt 400, "Invalid voter" unless voter.role == 'voter'
  
  invitation = @poll.invite_voter(voter, current_user)
  
  if invitation && invitation.persisted?
    log_user_action(Loggers.polls, 'voter_invited', { 
      poll_id: params[:id], 
      poll_title: @poll.title,
      voter_username: voter.username,
      invited_by: current_user.username
    })
    redirect "/polls/#{@poll.id}/invitations"
  else
    @error = invitation ? invitation.errors.full_messages.join(", ") : "Failed to create invitation"
    @invitations = @poll.poll_invitations.includes(:voter, :invited_by).order(:created_at)
    @available_voters = User.voters.where.not(id: @poll.poll_invitations.pluck(:voter_id))
    slim :'polls/invitations'
  end
end

delete '/polls/:id/invitations/:invitation_id' do
  require_organizer
  @poll = Poll.find(params[:id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  invitation = @poll.poll_invitations.find(params[:invitation_id])
  voter_username = invitation.voter.username
  invitation.destroy
  
  log_user_action(Loggers.polls, 'voter_invitation_removed', { 
    poll_id: params[:id], 
    poll_title: @poll.title,
    voter_username: voter_username,
    removed_by: current_user.username
  })
  redirect "/polls/#{@poll.id}/invitations"
end 