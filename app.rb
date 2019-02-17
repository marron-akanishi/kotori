require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'omniauth'
require 'omniauth-google-oauth2'

class App < Sinatra::Base
  # setting
  @@env = open('setting.json') do |io|
    JSON.load(io)
  end

  # config
  configure do
    set :sessions, true
    set :inline_templates, true
  end

  use OmniAuth::Builder do
    provider :google_oauth2, @@env["GOOGLE_APP_ID"], @@env["GOOGLE_APP_SECRET"]
  end

  # page
  get '/' do
    erb :index
  end

  get '/list' do
  end
  
  get '/mypage' do
  end

  post '/mypage' do
  end

  get '/search' do
  end

  get '/add' do
  end

  post '/add' do
  end

  get '/detail' do
  end

  get '/modify' do
  end

  post '/modify' do
  end

  # api
  get "/auth/:provider/callback" do
    @result = request.env["omniauth.auth"]
    @id = @result["uid"]
    @name = @result["info"]["name"]
  end

  delete '/delete' do
  end

  get '/logout' do
  end

  post '/quit' do
  end
end

App.run!