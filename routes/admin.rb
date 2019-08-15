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
          value = CGI.escapeHTML(obj.name)
          begin
            yomi = Kakasi.kakasi('-JH -KH', value)
          rescue => e
            yomi = value
          end
          if table.find(obj.id).name_yomi == nil then
            begin
              table.find(obj.id).update(name_yomi: normalize_str(yomi, true))
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
        User.find(params[:id]).update(name: CGI.escapeHTML(params["name"]), circle_id: params["circle"], author_id: params["author"])
      rescue => exception
        redirect to('/error?code=422')
      end
    #when "book" then
    when "author" then
      if Author.exists?(name: CGI.escapeHTML(params["name"])) then
        author_id = Author.find_by(name: CGI.escapeHTML(params["name"])).id
      elsif Author.exists?(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)) then
        author_id = Author.find_by(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)).id
      end
      # 完全に新しいか全く同じか
      if author_id == nil || author_id == params[:id].to_i then
        begin
          Author.find(params[:id]).update(name: CGI.escapeHTML(params["name"]), name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true), detail: CGI.escapeHTML(params["detail"]),
                                          twitter: CGI.escapeHTML(params["twitter"]), pixiv: CGI.escapeHTML(params["pixiv"]), web: CGI.escapeHTML(params["web"]), circle_id: params["circle"])
        rescue => exception
          redirect to('/error?code=422')
        end
      else
        BookAuthor.where(author_id: params[:id]).each do |obj|
          obj.update(author_id: author_id)
        end
        Author.find(params[:id]).delete
      end
    when "circle" then
      if Circle.exists?(name: CGI.escapeHTML(params["name"])) then
        circle_id = Circle.find_by(name: CGI.escapeHTML(params["name"])).id
      elsif Circle.exists?(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)) then
        circle_id = Circle.find_by(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)).id
      end
      if circle_id == nil || circle_id == params[:id].to_i then
        begin
          Circle.find(params["id"]).update(name: CGI.escapeHTML(params["name"]), name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true),
                                            detail: CGI.escapeHTML(params["detail"]), web: CGI.escapeHTML(params["web"]))
        rescue => exception
          redirect to('/error?code=422')
        end
      else
        Book.where(circle_id: params[:id]).each do |obj|
          obj.update(circle_id: circle_id)
        end
        Circle.find(params[:id]).delete
      end
    when "genre" then
      if Genre.exists?(name: CGI.escapeHTML(params["name"])) then
        genre_id = Genre.find_by(name: CGI.escapeHTML(params["name"])).id
      elsif Genre.exists?(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)) then
        genre_id = Genre.find_by(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)).id
      end
      if genre_id == nil || genre_id == params[:id].to_i then
        begin
          Genre.find(params["id"]).update(name: CGI.escapeHTML(params["name"]), name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true))
        rescue => exception
          redirect to('/error?code=422')
        end
      else
        BookGenre.where(genre_id: params[:id]).each do |obj|
          obj.update(genre_id: genre_id)
        end
        Genre.find(params[:id]).delete 
      end
    when "event" then
      if Event.exists?(name: CGI.escapeHTML(params["name"])) then
        event_id = Event.find_by(name: CGI.escapeHTML(params["name"])).id
      elsif Event.exists?(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)) then
        event_id = Event.find_by(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)).id
      end
      if event_id == nil || event_id == params[:id].to_i then
        begin
          Event.find(params["id"]).update(name: CGI.escapeHTML(params["name"]), name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true),
                                          start_at: CGI.escapeHTML(params["start"]), end_at: CGI.escapeHTML(params["end"]))
        rescue => exception
          redirect to('/error?code=422')
        end
      else
        Book.where(event_id: params[:id]).each do |obj|
          obj.update(event_id: event_id)
        end
        Event.find(params[:id]).delete
      end
    when "tag" then
      if Tag.exists?(name: CGI.escapeHTML(params["name"])) then
        tag_id = Tag.find_by(name: CGI.escape(params["name"])).id
      elsif Tag.exists?(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)) then
        tag_id = Tag.find_by(name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true)).id
      end
      if tag_id == nil || tag_id == params[:id].to_i then
        begin
          Tag.find(params["id"]).update(name: CGI.escapeHTML(params["name"]), name_yomi: normalize_str(CGI.escapeHTML(params["name_yomi"]), true))
        rescue => exception
          redirect to('/error?code=422')
        end
      else
        BookTag.where(ta_id: params[:id]).each do |obj|
          obj.update(tag_id: tag_id)
        end
        Tag.find(params[:id]).delete
      end
    end
    redirect to('/admin/'+params["type"])
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
    redirect to('/admin/'+params["type"])
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
    @type = params["type"]
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