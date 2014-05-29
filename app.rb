require 'sinatra/flash'
require './webfaction/endpoint.rb'

enable :sessions
set :session_secret, 'd%^[%fGTH0(#'

register do
  def auth(type)
    condition do
      redirect to('/login') unless send("is_#{type}?")
    end
  end
end

helpers do
  def is_user?
    @user != nil
  end

  def n2r(s)
    s.gsub(/\n/, "\r")
  end
end

before do
  @user = session[:username]
  @email = session[:email]
  @settings = session[:settings]
end

get '/', :auth => :user do
  haml :form
end

post '/', :auth => :user do
  begin
    endpoint = WebFaction::Endpoint.new(session[:username], session[:email])
    response = endpoint.edit_autoresponder(params)
    flash[:success] = "Settings successfully updated" if response
    session[:settings] = endpoint.email_settings
    puts "email settings: #{session[:settings]}"
    redirect to('/')
  rescue => e
    flash[:error] = e.message
    redirect to('/') 
  end
end

get '/login' do
  haml :login
end

post '/login' do
  if WebFaction::Endpoint.imap_credentials_valid?(params[:username], params[:password])
    begin
      endpoint = WebFaction::Endpoint.new(params[:username], params[:email])
      session[:username] = params[:username]
      session[:email] = params[:email]
      session[:settings] = endpoint.email_settings
      redirect to('/') 
    rescue Exception => e
      flash[:error] = {login: e.message}
      redirect to('/login')
    end
  end
  flash[:error] = {login: "The entered username or password are invalid"}
  redirect to('/login')
end

get '/logout' do
  session[:username] = nil
  session[:email] = nil
  session[:settings] = nil
  redirect to('/login')
end

