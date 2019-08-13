require 'json'
require 'time'
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

  # config
  configure do
    set :sessions, true
    set :session_secret, @@env["SESSION_SECRET"]
    set :inline_templates, true
    set :public_dir, File.dirname(__FILE__) + '/public'
  end

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

  @@error_msg = {
    "403" => "ログインが禁止されています",
    "404" => "指定されたURLが見つかりません",
    "422" => "DBとの整合性チェックに失敗しました",
    "500" => "エラーが発生しました"
  }
end

Dir[File.dirname(__FILE__) + "/routes/**"].each do |route|
  require route
end