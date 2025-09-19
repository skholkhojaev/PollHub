get '/polls/:poll_id/questions/:question_id/options/new' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:question_id])
  slim :'options/new'
end

post '/polls/:poll_id/questions/:question_id/options' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:question_id])
  
  @option = Option.new(
    question_id: @question.id,
    text: params[:text]
  )
  
  if @option.save
    if params[:add_another] == "1"
      redirect "/polls/#{@poll.id}/questions/#{@question.id}/options/new"
    else
      redirect "/polls/#{@poll.id}"
    end
  else
    @error = @option.errors.full_messages.join(", ")
    slim :'options/new'
  end
end

get '/polls/:poll_id/questions/:question_id/options/:id/edit' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:question_id])
  @option = Option.find(params[:id])
  slim :'options/edit'
end

patch '/polls/:poll_id/questions/:question_id/options/:id' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:question_id])
  @option = Option.find(params[:id])
  
  if @option.update(
    text: params[:text]
  )
    redirect "/polls/#{@poll.id}"
  else
    @error = @option.errors.full_messages.join(", ")
    slim :'options/edit'
  end
end

delete '/polls/:poll_id/questions/:question_id/options/:id' do
  require_organizer
  @poll = Poll.find(params[:poll_id])
  halt 403 unless current_user.id == @poll.organizer_id || admin?
  @question = Question.find(params[:question_id])
  @option = Option.find(params[:id])
  
  @option.destroy
  redirect "/polls/#{@poll.id}"
end 