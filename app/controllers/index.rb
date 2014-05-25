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
  p @user
if params[:create][:password_hash] != ""
  @user.save
  @user.password = params[:create][:password_hash]
  @user.save
  session[:user_id] = @user.id
  # redirect '/'

end
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
  SurveyedUser.create(user_id: session[:user_id], survey_id: params[:survey_id])

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
  puts params[:choices]
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

  Survey.find(params[:survey_id])

  erb :survey_results

end

get '/survey/:survey_id/delete' do
  survey = Survey.find_by_id(params[:survey_id])
  survey.questions.destroy_all
  survey.destroy
  redirect '/user_profile'
end
