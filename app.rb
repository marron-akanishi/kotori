require 'json'
require 'time'
require 'securerandom'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'rmagick'
# DB
require 'sinatra/activerecord'
Dir[File.dirname(__FILE__) + "/models/**"].each do |model|
  require model
end

class App < Sinatra::Base
  # setting
  @@env = open('setting.json') do |io|
    JSON.load(io)
  end

  # config
  configure do
    set :sessions, true
    set :session_secret, @@env["SESSION_SECRET"]
    set :inline_templates, true
    set :public_dir, File.dirname(__FILE__) + '/public'
  end

  use OmniAuth::Builder do
    provider :google_oauth2, @@env["GOOGLE_APP_ID"], @@env["GOOGLE_APP_SECRET"]
  end

  # helper
  helpers do
    def login_check
      if session[:id] == nil then
        redirect to('/')
      end
    end

    def boolean_check(value)
      return value == 'true' ? true : false
    end
  end
end

Dir[File.dirname(__FILE__) + "/routes/**"].each do |route|
  require route
end