class App < Sinatra::Base
  get '/admin' do
    admin_check
    erb :admin, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
  end

  get '/admin/setting' do
    admin_check
    erb :admin_setting, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
  end

  post '/admin/setting/done' do
    admin_check
    redirect to('/admin')
  end

  get '/admin/setting/done' do
    admin_check
    case params["type"]
    when "yomi_update" then
      [Author, Circle, Genre, Event, Tag].each do |table|
        table.all.each do |obj|
          begin
            yomi = Kakasi.kakasi('-JH -KH', obj.name)
          rescue => e
            yomi = obj.name
          end
          if table.find(obj.id).name_yomi == nil then
            begin
              table.find(obj.id).update(name_yomi: yomi)
            rescue => e
              redirect to("/error?code=512")
            end
          end
        end
      end
    end
    redirect to('/admin')
  end

  get '/admin/status' do
    admin_check
    @wakeup = Time.at($version)
    @count = {}
    @count["user"] = User.count
    @count["book"] = Book.count
    @count["author"] = Author.count
    @count["circle"] = Circle.count
    @count["genre"] = Genre.count
    @count["event"] = Event.count
    @count["tag"] = Tag.count
    erb :admin_status, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
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
        Author.find(params[:id]).update(name: params["name"], name_yomi: params["name_yomi"], detail: params["detail"], twitter: params["twitter"],
                                        pixiv: params["pixiv"], web: params["web"], circle_id: params["circle"])
      rescue => exception
        redirect to('/error?code=422')
      end
    when "circle" then
      begin
        Circle.find(params["id"]).update(name: params["name"], name_yomi: params["name_yomi"], detail: params["detail"], web: params["web"])
      rescue => exception
        redirect to('/error?code=422')
      end
    when "genre" then
      begin
        Genre.find(params["id"]).update(name: params["name"], name_yomi: params["name_yomi"])
      rescue => exception
        redirect to('/error?code=422')
      end
    when "event" then
      begin
        Event.find(params["id"]).update(name: params["name"], name_yomi: params["name_yomi"], start_at: params["start"], end_at: params["end"])
      rescue => exception
        redirect to('/error?code=422')
      end
    when "tag" then
      begin
        Tag.find(params["id"]).update(name: params["name"], name_yomi: params["name_yomi"])
      rescue => exception
        redirect to('/error?code=422')
      end
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
      erb :admin_user_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "book" then
      @detail = Book.find(params["id"])
      erb :admin_book_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "author" then
      @detail = Author.find(params["id"])
      erb :admin_author_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "circle" then
      @detail = Circle.find(params["id"])
      erb :admin_circle_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "genre" then
      @detail = Genre.find(params["id"])
      erb :admin_genre_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "event" then
      @detail = Event.find(params["id"])
      erb :admin_event_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    when "tag" then
      @detail = Tag.find(params["id"])
      erb :admin_tag_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
    end
  end

  get '/admin/:type' do
    admin_check
    @type = params["type"][0, params["type"].length-1]
    @type_name = @@type_list[@type]
    case @type
    when "user" then
      @list = User.all
    when "book" then
      @list = Book.all
    when "author" then
      @list = Author.all
    when "circle" then
      @list = Circle.all
    when "genre" then
      @list = Genre.all
    when "event" then
      @list = Event.all
    when "tag" then
      @list = Tag.all
    end
    erb :admin_list, :layout_options => { :views => settings.views }, :views => settings.views + '/admin'
  end
end