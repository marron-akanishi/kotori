class App < Sinatra::Base
  get '/book' do
    @type_name = "書籍"
    @type = "book"
    erb :list
  end

  get '/book/:id' do
    @from = params["from"]
    @book = Book.includes(:event, :circle).find(params["id"])
    @genre = Genre.find(BookGenres.find_by(book_id: @book.id, is_main:true).genre_id)
    @author = Author.find(BookAuthors.find_by(book_id: @book.id, is_main:true).author_id)
    if @book.event != nil then
      @event = @book.event
    else
      @event = ""
    end
    @circle = @book.circle
    @user = @book.user.name
    if session[:id] != nil && UserBooks.exists?(user_id: session[:id], book_id: params["id"])then
      @owned = true;
      @memo = UserBooks.find_by(user_id: session[:id], book_id: params["id"]).memo
    end
    erb :book_detail, :views => settings.views + '/book'
  end

  get '/book/add/title' do
    login_check
    erb :book_add_title, :views => settings.views + '/book'
  end

  post '/book/add/detail' do
    login_check
    case params["mode"]
      when "manual" then
        @detail = {}
        @title = params["title"]
      when "melon" then
        @detail = SiteParser.melon(params["url"])
        @title = @detail[:title]
      when "tora" then
        @detail = SiteParser.tora(params["url"])
        @title = @detail[:title]
      when "lashin" then
        @detail = SiteParser.lashin(params["url"])
        @title = @detail[:title]
    end
    if Book.exists?(title: @title) then
      @exists = Book.find_by(title: @title)
      @author = Author.where(id: BookAuthors.where(book_id: @exists.id, is_main: true).select(:author_id)).first.name
    end
    erb :book_add_detail, :views => settings.views + '/book'
  end

  post '/book/add/done' do
    login_check
    # 表紙画像保存
    if params["cover-img"] != nil then
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
    elsif params["image-url"] != "" then
      filename = SecureRandom.uuid + ".jpg"
      image = Magick::ImageList.new
      image.from_blob(open(params["image-url"]).read)
      begin
        image = Magick::ImageList.new
        image.from_blob(open(params["image-url"]).read)
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
    # タグ(未対応)
    # ジャンル(複数未対応)
    if Genre.exists?(name: params["genre"]) then
      genre = Genre.find_by(name: params["genre"])
    else
      genre = Genre.create(name: params["genre"])
    end
    # 著者(複数未対応)
    if Author.exists?(name: params["author"]) then
      author = Author.find_by(name: params["author"])
    else
      author = Author.create(name: params["author"])
    end
    # イベント
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event = Event.find_by(name: params["event"])
      else
        event = Event.create(name: params["event"])
      end
    end
    # サークル
    if Circle.exists?(name: params["circle"]) then
      circle = Circle.find_by(name: params["circle"])
    else
      circle = Circle.create(name: params["circle"])
    end
    # 18禁
    is_adult = boolean_check(params["is-adult"])
    # 書籍登録
    # 順番に登録していく
    book = Book.create(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                       mod_user: session[:id], event_id: event.id, circle_id: circle.id)
    BookGenres.create(book_id: book.id, genre_id: genre.id, is_main: true)
    BookAuthors.create(book_id: book.id, author_id: author.id, is_main: true)
    # 所持状況更新
    UserBooks.create(user_id: session[:id], book_id: book.id)
    redirect to('/user/mypage')
  end

  get '/book/:id/modify' do
    login_check
    @from = params["from"]
    @book = Book.includes(:event, :circle).find(params["id"])
    @genre = Genre.find(BookGenres.find_by(book_id: @book.id, is_main:true).genre_id).name
    @author = Author.find(BookAuthors.find_by(book_id: @book.id, is_main:true).author_id).name
    if @book.event != nil then
      @event = @book.event.name
    else
      @event = ""
    end
    @circle = @book.circle.name
    erb :book_modify, :views => settings.views + '/book'
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
    
    # DB更新
    # タグ(未対応)
    # ジャンル(複数未対応)
    if Genre.exists?(name: params["genre"]) then
      genre = Genre.find_by(name: params["genre"])
    else
      genre = Genre.create(name: params["genre"])
    end
    # 著者(複数未対応)
    if Author.exists?(name: params["author"]) then
      author = Author.find_by(name: params["author"])
    else
      author = Author.create(name: params["author"])
    end
    # イベント
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event = Event.find_by(name: params["event"])
      else
        event = Event.create(name: params["event"])
      end
    end
    # サークル
    if Circle.exists?(name: params["circle"]) then
      circle = Circle.find_by(name: params["circle"])
    else
      circle = Circle.create(name: params["circle"])
    end
    # 18禁
    is_adult = boolean_check(params["is-adult"])
    # 書籍登録
    # 順番に登録していく
    book = Book.find(params[:id]).update(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                                         mod_user: session[:id], event_id: event.id, circle_id: circle.id)
    BookGenres.where(book_id: params[:id], is_main: true).first.update(genre_id: genre.id)
    BookAuthors.where(book_id: params[:id], is_main: true).first.update(author_id: author.id)

    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end
end