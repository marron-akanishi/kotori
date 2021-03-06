require 'json'
require 'time'
require 'cgi/escape'
require 'sinatra'
require 'sinatra/reloader'
require 'omniauth'
require 'omniauth-google-oauth2'
require 'kakasi'
require './SiteParser'
require './Helper'
# DB
require 'sinatra/activerecord'
Dir[File.dirname(__FILE__) + "/models/**"].each do |model|
  require model
end

class App < Sinatra::Base
  include SiteParser
  include Helper

  # setting
  $version = Time.now.to_i
  @@env = open('setting.json') do |io|
    JSON.load(io)
  end
  Time.zone = "Tokyo"
  ActiveRecord::Base.default_timezone = :local
  ActiveRecord::Base.configurations = YAML.load_file('./database.yml')
  ActiveRecord::Base.establish_connection(:development)

  # config
  configure do
    set :sessions, true
    set :session_secret, @@env["SESSION_SECRET"]
    set :inline_templates, true
    set :public_dir, File.dirname(__FILE__) + '/public'
  end

  OmniAuth.config.full_host = @@env["DOMEIN"]
  use OmniAuth::Strategies::Developer
  use OmniAuth::Builder do
    provider :google_oauth2, @@env["GOOGLE_APP_ID"], @@env["GOOGLE_APP_SECRET"], { :skip_jwt => true }
  end

  helpers Helper

  # error
  error 404 do
    redirect to("/error?code=404")
  end

  error 500 do
    redirect to("/error?code=500")
  end

  # types
  @@type_list = {
    "user" => "ユーザー",
    "book" => "登録書籍",
    "author" => "著者",
    "circle" => "サークル",
    "genre" => "ジャンル",
    "event" => "イベント",
    "tag" => "タグ"
  }
end

Dir[File.dirname(__FILE__) + "/routes/**"].each do |route|
  require route
end