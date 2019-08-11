class App < Sinatra::Base
  get '/admin' do
    admin_check
    erb :admin, :views => settings.views + '/admin'
  end

  get '/admin/setting' do
    admin_check
  end

  post '/admin/setting/done' do
    admin_check
  end

  get '/admin/status' do
    admin_check
  end

  post '/admin/:type/:id/modify' do
    admin_check
    case params["type"]
    when "user" then
      begin
        User.find(params[:id]).update(name: params["name"], circle_id: params["circle"], author_id: params["author"])
      rescue => exception
        redirect to('/error?code=422')
      end
    #when "book" then
    when "author" then
      begin
        Author.find(params[:id]).update(name: params["name"], detail: params["detail"], twitter: params["twitter"],
                                        pixiv: paramas["pixiv"], web: params["web"], circle_id: params["circle"])
      rescue => exception
        redirect to('/error?code=422')
      end
    when "circle" then
      Circle.find(params["id"]).update(name: params["name"], detail: params["detail"], web: params["web"])
    when "genre" then
      Genre.find(params["id"]).update(name: params["name"])
    when "event" then
      Event.find(params["id"]).update(name: params["name"], start_at: params["start"], end_at: params["end"])
    when "tag" then
      Tag.find(params["id"]).update(name: params["name"])
    end
    redirect to('/admin/'+params["type"]+'s')
  end
  
  # userとbook以外は一括削除のみ対応(idは常時0)
  get '/admin/:type/:id/delete' do
    admin_check
    case params["type"]
    when "user" then
      User.find(params["id"]).update(deleted_at: Time.now)
    when "book" then
      Book.find(params["id"]).destroy
    when "author" then
      Author.all.each do |obj|
        if !BookAuthor.exists?(author_id: obj.id) then
          Author.find(obj.id).destroy
        end
      end
    when "circle" then
      Circle.all.each do |obj|
        if !Book.exists?(circle_id: obj.id) then
          Circle.find(obj.id).destroy
        end
      end
    when "genre" then
      Genre.all.each do |obj|
        if !BookGenre.exists?(genre_id: obj.id) then
          Genre.find(obj.id).destroy
        end
      end
    when "event" then
      Event.all.each do |obj|
        if !Book.exists?(event_id: obj.id) then
          Event.find(obj.id).destroy
        end
      end
    when "tag" then
      Tag.all.each do |obj|
        if !BookTag.exists?(tag_id: obj.id) then
          Tag.find(obj.id).destroy
        end
      end
    end
    redirect to('/admin/'+params["type"]+'s')
  end

  get '/admin/:type/:id' do
    admin_check
    case params["type"]
    when "user" then
      @detail = User.find(params["id"])
      erb :admin_user_detail, :views => settings.views + '/admin'
    when "book" then
      @detail = Book.find(params["id"])
      erb :admin_book_detail, :views => settings.views + '/admin'
    when "author" then
      @detail = Author.find(params["id"])
      erb :admin_author_detail, :views => settings.views + '/admin'
    when "circle" then
      @detail = Circle.find(params["id"])
      erb :admin_circle_detail, :views => settings.views + '/admin'
    when "genre" then
      @detail = Genre.find(params["id"])
      erb :admin_genre_detail, :views => settings.views + '/admin'
    when "event" then
      @detail = Event.find(params["id"])
      erb :admin_event_detail, :views => settings.views + '/admin'
    when "tag" then
      @detail = Tag.find(params["id"])
      erb :admin_tag_detail, :views => settings.views + '/admin'
    end
  end

  get '/admin/:type' do
    admin_check
    case params["type"]
    when "users" then
      @type_name = "ユーザー"
      @type = "user"
      @list = User.all
    when "books" then
      @type_name = "登録書籍"
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
    when "tags" then
      @type_name = "タグ"
      @type = "tag"
      @list = Tag.all
    end
    erb :admin_list, :views => settings.views + '/admin'
  end
end