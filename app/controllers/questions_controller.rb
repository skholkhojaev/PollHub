get '/polls/:poll_id/questions/new' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  slim :'questions/new'
end

post '/polls/:poll_id/questions' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  
  @question = Question.new(
    poll_id: @poll.id,
    text: params[:text],
    question_type: params[:question_type]
  )
  
  if @question.save
    redirect "/polls/#{@poll.id}/questions/#{@question.id}/options/new"
  else
    @error = @question.errors.full_messages.join(", ")
    slim :'questions/new'
  end
end

get '/polls/:poll_id/questions/:id/edit' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:id])
  slim :'questions/edit'
end

patch '/polls/:poll_id/questions/:id' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:id])
  
  if @question.update(
    text: params[:text],
    question_type: params[:question_type]
  )
    redirect "/polls/#{@poll.id}"
  else
    @error = @question.errors.full_messages.join(", ")
    slim :'questions/edit'
  end
end

delete '/polls/:poll_id/questions/:id' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:id])
  
  @question.destroy
  redirect "/polls/#{@poll.id}"
end 