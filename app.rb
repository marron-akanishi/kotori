require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'time'
require 'omniauth'
require 'omniauth-google-oauth2'
# DB
require 'sinatra/activerecord'
require './models/user.rb'
require './models/book.rb'
require './models/genre.rb'
require './models/event.rb'
require './models/author.rb'
require './models/circle.rb'
require './models/owner.rb'

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

  # routing
  get '/' do
    erb :index
  end

  get '/list' do
    @name = User.find(session[:id]).name
    erb :list
  end

  get '/add/title' do
    erb :add
  end

  post '/add/detail' do
  end

  post '/add/done' do
  end

  get '/detail' do
  end

  get '/modify' do
  end

  post '/modify/done' do
  end

  get '/mypage' do
  end

  post '/mypage/modify' do
  end

  get '/search' do
  end
  get "/auth/:provider/callback" do
    result = request.env["omniauth.auth"]
    session[:id] = result["uid"]
    if User.exists?(id: session[:id]) then
      User.find(session[:id]).update(latest_at: Time.now)
    else
      name = result["info"]["name"]
      User.create(id: id, name: @name, latest_at: Time.now)
    end
    redirect to('/list')
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end

App.run!