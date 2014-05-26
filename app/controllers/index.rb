get '/' do
  if session[:user_id]
    @user = User.find(session[:user_id])
  end
  erb :index
end

get '/signup' do

  erb :signup
end

post '/signup' do
  @user = User.new(params[:create])
  @user.password = params[:create][:password_hash]
  @user.save
  session[:user_id] = @user.id
  erb :index
end

get '/login' do

  erb :login
end

post '/login' do
  @user = User.find_by_username(params[:login][:username])
  if @user.password == params[:login][:password_hash]
    session[:user_id] = @user.id
  else
    session[:message] = "Login did not work"
  end
  redirect '/'
end

get '/logout' do
  session.clear
  redirect '/'
end

get '/surveys' do
  @surveys = Survey.all
  @users = User.all
  erb :surveys
end

get '/take_survey/:survey_id' do
  @survey = Survey.find_by_id(params[:survey_id])
  erb :'take_survey/survey'
end

post '/take_survey/:survey_id/submit' do
  surveyed_user = SurveyedUser.create(user_id: session[:user_id],
                                      survey_id: params[:survey_id])
  params[:choices].each do |question_id, choice_id|
    Response.create(surveyed_user_id: surveyed_user.id,
                    question_id: question_id,
                    choice_id: choice_id)
  end

  redirect 'surveys'
end

get '/surveys/create' do

  erb :'create_survey/create'
end

post '/survey/new' do
  title = params[:survey][:title]
  session[:title] = title
  survey = Survey.create(title: title, user_id: session[:user_id])
  session[:survey_id] = survey.id
  redirect '/surveys/create'
end

post '/survey/new_question' do
  survey_id = session[:survey_id]
  question_title = params[:question][:question]
  question = Question.create(question: question_title, survey_id: survey_id)
  session[:question_id] = question.id
  redirect '/surveys/create'
end

post '/finished' do
  session.delete(:title)
  redirect '/'
end

post '/choices' do
  params[:choices].each do |key, val|
    Choice.create(choice: val, question_id: session[:question_id])
  end
  redirect '/surveys/create'
end

get '/user_profile' do

  @current_user = User.find(session[:user_id])
  @user_surveys = Survey.where(user_id: session[:user_id])

  erb :profile
end

get '/survey/:survey_id/results' do
  @survey = Survey.find(params[:survey_id])
  @surveyed_users = SurveyedUser.where(survey_id: @survey.id)

  erb :survey_results

end

get '/survey/:survey_id/edit' do
  @survey = Survey.find(params[:survey_id])

  erb :'create_survey/edit_survey'
end

get '/survey/:survey_id/question/:question_id/edit' do
  @survey = Survey.find(params[:survey_id])
  @question = Question.find(params[:question_id])
  erb :'create_survey/edit_question'
end

post '/survey/:survey_id/question/:question_id/edit' do
  @survey = Survey.find(params[:survey_id])
  @question = Question.find(params[:question_id])
  choices = params[:choices]
  Question.update(@question.id, question: params[:question][:question])
  choices.each do |choice|
    Choice.update(choice[0], choice: choice[1])
  end
  redirect "/survey/#{@survey.id}/edit"
end

get '/survey/:survey_id/delete' do
  survey = Survey.find(params[:survey_id])
  #destroy all data for survey's surveyed users
  SurveyedUser.where(survey_id: params[:survey_id]).destroy_all
  #destroy all data for responses to survey
  # Response.where()
  #destroy all choices related to question
  survey.questions.each do |question|
    question.choices.destroy_all
  end
  #destroy all questions related to survey
  survey.questions.destroy_all
  #destroys the survey
  survey.destroy
  redirect '/user_profile'
end
