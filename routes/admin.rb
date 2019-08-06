class App < Sinatra::Base
  get '/admin' do
    admin_check
    erb :admin, :views => settings.views + '/admin'
  end

  get '/admin/setting' do
  end

  post '/admin/setting/done' do
  end

  get '/admin/status' do
  end

  post '/admin/:type/:id/modify' do
    case params["type"]
    when "user" then
    when "book" then
    when "author" then
    when "circle" then
    when "genre" then
    when "event" then
    end
    redirect to('/admin/'+params["type"]+'/'+params["id"])
  end
  
  post '/admin/:type/:id/delete' do
    case params["type"]
    when "user" then
    when "book" then
    when "author" then
    when "circle" then
    when "genre" then
    when "event" then
    end
    redirect to('/admin/'+params["type"]+'s')
  end

  get '/admin/:type/:id' do
    case params["type"]
    when "user" then
      erb :admin_user_detail, :views => settings.views + '/admin'
    when "book" then
      erb :admin_book_detail, :views => settings.views + '/admin'
    when "author" then
      erb :admin_author_detail, :views => settings.views + '/admin'
    when "circle" then
      erb :admin_circle_detail, :views => settings.views + '/admin'
    when "genre" then
      erb :admin_genre_detail, :views => settings.views + '/admin'
    when "event" then
      erb :admin_event_detail, :views => settings.views + '/admin'
    end
  end

  get '/admin/:type' do
    case params["type"]
    when "users" then
      @type_name = "ユーザー"
      @type = "user"
      @list = User.all
    when "books" then
      @type_name = "書籍"
      @type = "book"
      @list = Book.all
    when "authors" then
      @type_name = "著者"
      @type = "author"
      @list = Author.all
    when "circles" then
      @type_name = "サークル"
      @type = "circle"
      @list = Circle.all
    when "genres" then
      @type_name = "ジャンル"
      @type = "genre"
      @list = Genre.all
    when "events" then
      @type_name = "イベント"
      @type = "event"
      @list = Event.all
    end
    erb :admin_list, :views => settings.views + '/admin'
  end
end