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
    set :session_secret, @@env["SESSION_SECRET"]
    set :inline_templates, true
    set :public, File.dirname(__FILE__) + '/public'
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

  # routing
  get '/' do
    if session[:id] != nil then
      redirect to('/list')
    end
    erb :index
  end

  get '/error' do
    erb :error
  end

  get '/list' do
    login_check
    @name = User.find(session[:id]).name
    @list = []
    Owner.where(user_id: session[:id]).find_each do |book|
      @list << Book.find(book.book_id)
    end
    erb :list
  end

  get '/add/title' do
    login_check
    erb :add_title
  end

  post '/add/detail' do
    login_check
    @title = params["title"]
    if Book.exists?(title: @title) then
      puts "見つけたよ"
    end
    erb :add_detail
  end

  post '/add/done' do
    login_check
    # 表紙画像保存
    filename = SecureRandom.uuid + ".jpg"
    begin
      image = Magick::Image.read(params["cover-img"]["tempfile"].path)[0]
    rescue => exception
      redirect to("/error")
    end
    if !["BMP","JPEG","PNG"].include?(image.format) then
      redirect to("/error")
    end
    image.resize_to_fit!(300)
    image.write("./public/images/cover/"+filename)
    image.destroy!
    # DB保存
    # ジャンル
    if Genre.exists?(name: params["genre"]) then
      genre_id = Genre.find_by(name: params["genre"]).id
    else
      genre = Genre.create(name: params["genre"])
      genre_id = genre.id
    end
    # サークル
    if Circle.exists?(name: params["circle"]) then
      circle_id = Circle.find_by(name: params["circle"]).id
    else
      circle = Circle.create(name: params["circle"])
      circle_id = circle.id
    end
    # 著者
    if Author.exists?(name: params["author"]) then
      author_id = Author.find_by(name: params["author"]).id
    else
      author = Author.create(name: params["author"])
      author_id = author.id
    end
    # イベント
    if Event.exists?(name: params["event"]) then
      event_id = Event.find_by(name: params["event"]).id
    else
      event = Event.create(name: params["event"])
      event_id = event.id
    end
    # 書籍
    is_adult = boolean_check(params["is-adult"])
    book = Book.create(title: params["title"], cover: filename, date: params["date"], is_adult: is_adult,
                      genre_id: genre_id, event_id: event_id, author_id: author_id, circle_id: circle_id, detail: params["detail"])
    # 所持状況更新
    Owner.create(user_id: session[:id], book_id: book.id)
    redirect to('/list')
  end

  get '/detail/:id' do
    login_check
    @book_detail = Book.find(params["id"])
    @genre = Genre.find(@book_detail.genre_id).name
    @event = Event.find(@book_detail.event_id).name
    @author = Author.find(@book_detail.author_id).name
    @circle = Circle.find(@book_detail.circle_id).name
    erb :detail
  end

  get '/modify' do
    login_check
  end

  post '/modify/done' do
    login_check
  end

  get '/mypage' do
    login_check
  end

  post '/mypage/modify' do
    login_check
  end

  get '/search' do
    login_check
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