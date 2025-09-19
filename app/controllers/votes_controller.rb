post '/polls/:poll_id/vote' do
  require_login
  @poll = Poll.find(params[:poll_id])
  
  halt 403 unless @poll.active?
  
  # Check if votes param exists
  if !params[:votes] || params[:votes].empty?
    log_user_action(Loggers.polls, 'vote_attempt_failed_no_selection', { 
      poll_id: params[:poll_id], 
      poll_title: @poll.title 
    })
    @error = "Please select at least one option to vote"
    redirect "/polls/#{@poll.id}"
    return
  end
  
  vote_details = []
  total_votes_cast = 0
  
  # Process vote for each question
  params[:votes].each do |question_id, option_data|
    question = Question.find(question_id)
    
    if question.single_choice?
      # Single choice question
      option_id = option_data.to_i
      next if option_id.zero?
      
      # Delete any existing votes by this user for this question
      existing_votes = Vote.where(user_id: current_user.id, question_id: question_id)
      if existing_votes.any?
        log_user_action(Loggers.polls, 'existing_votes_deleted_for_revote', { 
          poll_id: params[:poll_id], 
          question_id: question_id,
          deleted_votes_count: existing_votes.count 
        })
        existing_votes.destroy_all
      end
      
      # Create new vote
      vote = Vote.create(
        user_id: current_user.id,
        option_id: option_id,
        question_id: question_id
      )
      
      if vote.persisted?
        total_votes_cast += 1
        vote_details << { question_id: question_id, option_id: option_id, type: 'single_choice' }
      end
    else
      # Multiple choice question
      # Check if at least one option is selected
      selected_options = option_data.select { |_, is_selected| is_selected == "1" }
      next if selected_options.empty?
      
      option_data.each do |option_id, is_selected|
        next unless is_selected == "1"
        
        # Check if vote already exists
        existing_vote = Vote.find_by(
          user_id: current_user.id,
          option_id: option_id,
          question_id: question_id
        )
        
        unless existing_vote
          vote = Vote.create(
            user_id: current_user.id,
            option_id: option_id,
            question_id: question_id
          )
          
          if vote.persisted?
            total_votes_cast += 1
            vote_details << { question_id: question_id, option_id: option_id, type: 'multiple_choice' }
          end
        end
      end
    end
  end
  
  if total_votes_cast > 0
    log_user_action(Loggers.polls, 'votes_cast_successfully', { 
      poll_id: params[:poll_id], 
      poll_title: @poll.title,
      total_votes_cast: total_votes_cast,
      vote_details: vote_details,
      voter: current_user.username 
    })
  else
    log_user_action(Loggers.polls, 'vote_attempt_failed_no_valid_selections', { 
      poll_id: params[:poll_id], 
      poll_title: @poll.title 
    })
  end
  
  redirect "/polls/#{@poll.id}/results"
end 