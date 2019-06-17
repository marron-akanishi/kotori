class App < Sinatra::Base
  get '/book' do
    @type_name = "書籍"
    @type = "book"
    erb :list
  end

  get '/book/:id' do
    @from = params["from"]
    @book_detail = Book.includes(:genre, :event, :author, :circle, :user).find(params["id"])
    @genre = @book_detail.genre.name
    if @book_detail.event != nil then
      @event = @book_detail.event.name
    else
      @event = ""
    end
    @author = @book_detail.author.name
    @circle = @book_detail.circle.name
    @user = @book_detail.user.name
    if session[:id] != nil && Owner.exists?(user_id: session[:id], book_id: params["id"])then
      @owned = true;
      @memo = Owner.find_by(user_id: session[:id], book_id: params["id"]).memo
    end
    erb :book_detail
  end

  get '/book/add/title' do
    login_check
    erb :book_add_title
  end

  post '/book/add/detail' do
    login_check
    @title = params["title"]
    if Book.exists?(title: @title) then
      @exists = Book.find_by(title: @title)
      @author = Author.find(@exists.author_id).name
    end
    erb :book_add_detail
  end

  post '/book/add/done' do
    login_check
    if params["cover-img"] != nil then
      # 表紙画像保存
      filename = SecureRandom.uuid + ".jpg"
      begin
        image = Magick::Image.read(params["cover-img"]["tempfile"].path)[0]
      rescue => exception
        redirect to("/error?code=500")
      end
      if !["BMP","JPEG","PNG"].include?(image.format) then
        redirect to("/error?code=500")
      end
      image.resize_to_fit!(1000, 300)
      image.write("./public/images/cover/"+filename)
      image.destroy!
    else
      filename = "noimage.png"
    end
    
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
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event_id = Event.find_by(name: params["event"]).id
      else
        event = Event.create(name: params["event"])
        event_id = event.id
      end
    end
    # 書籍
    is_adult = boolean_check(params["is-adult"])
    book = Book.create(title: params["title"], cover: filename, date: params["date"], is_adult: is_adult, mod_user: session[:id],
                      genre_id: genre_id, event_id: event_id, author_id: author_id, circle_id: circle_id, detail: params["detail"])
    # 所持状況更新
    Owner.create(user_id: session[:id], book_id: book.id)
    redirect to('/user/mypage')
  end

  get '/book/:id/modify' do
    login_check
    @from = params["from"]
    @book_detail = Book.includes(:genre, :event, :author, :circle).find(params["id"])
    @genre = @book_detail.genre.name
    if @book_detail.event != nil then
      @event = @book_detail.event.name
    else
      @event = ""
    end
    @author = @book_detail.author.name
    @circle = @book_detail.circle.name
    erb :book_modify
  end

  post '/book/:id/modify/done' do
    login_check
    if params["cover-img"] != nil then
      # 表紙画像保存
      filename = SecureRandom.uuid + ".jpg"
      begin
        image = Magick::Image.read(params["cover-img"]["tempfile"].path)[0]
      rescue => exception
        redirect to("/error?code=500")
      end
      if !["BMP","JPEG","PNG"].include?(image.format) then
        redirect to("/error?code=500")
      end
      image.resize_to_fit!(1000, 300)
      image.write("./public/images/cover/"+filename)
      image.destroy!
    else
      filename = params["orig-cover"]
    end
    
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
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event_id = Event.find_by(name: params["event"]).id
      else
        event = Event.create(name: params["event"])
        event_id = event.id
      end
    end
    # 書籍
    is_adult = boolean_check(params["is-adult"])
    Book.find(params[:id]).update(title: params["title"], cover: filename, date: params["date"], is_adult: is_adult, mod_user: session[:id],
                                  genre_id: genre_id, event_id: event_id, author_id: author_id, circle_id: circle_id, detail: params["detail"])
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end
end