class App < Sinatra::Base
  get '/book' do
    @type_name = "書籍"
    @type = "book"
    erb :list
  end

  get '/book/:id' do
    @from = params["from"]
    @book = Book.includes(:authors, :genres, :tags, :user, :event, :circle).find(params["id"])
    if session[:id] != nil && UserBook.exists?(user_id: session[:id], book_id: params["id"])then
      @owned = true;
      @memo = UserBook.find_by(user_id: session[:id], book_id: params["id"]).memo
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
    @exists = []
    # タイトル存在チェック
    Book.all.each do |obj|
      # カナ→ひら、半角化、スペース削除、大文字小文字無視
      target = @title.tr('ァ-ン','ぁ-ん')
      check = obj.title.tr('ァ-ン','ぁ-ん')
      target = target.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
      check = check.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
      target = target.gsub(/(\s|　)+/, '')
      check = check.gsub(/(\s|　)+/, '')
      if target.upcase == check.upcase then
        @exists.push(Book.includes(:authors).find(obj.id))
      end
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
    # タグ
    tag_list = params["tag"].split(",")
    tags = []
    tag_list.each do |value|
      if value == "" then
        next
      end
      if Tag.exists?(name: value) then
        tag = Tag.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        tag = Tag.create(name: value, name_yomi: yomi)
      end
      tags.push(tag.id)
    end
    # ジャンル
    genre_list = params["genre"].split(",")
    genres = []
    genre_list.each do |value|
      if value == "" then
        next
      end
      if Genre.exists?(name: value) then
        genre = Genre.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        genre = Genre.create(name: value, name_yomi: yomi)
      end
      genres.push(genre.id)
    end
    # 著者
    author_list = params["author"].split(",")
    authors = []
    author_list.each do |value|
      if value == "" then
        next
      end
      if Author.exists?(name: value) then
        author = Author.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        author = Author.create(name: value, name_yomi: yomi)
      end
      authors.push(author.id)
    end
    # イベント
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event = Event.find_by(name: params["event"])
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', params["event"])
        rescue => exception
          yomi = params["event"]
        end
        event = Event.create(name: params["event"], name_yomi: yomi)
      end
    end
    # サークル
    if Circle.exists?(name: params["circle"]) then
      circle = Circle.find_by(name: params["circle"])
    else
      begin
          yomi = Kakasi.kakasi('-JH -KH', params["circle"])
        rescue => exception
          yomi = params["circle"]
        end
      circle = Circle.create(name: params["circle"], name_yomi: yomi)
    end
    # 18禁
    is_adult = boolean_check(params["is-adult"])
    # 書籍登録
    # 順番に登録していく
    book = Book.create(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                       mod_user: session[:id], event_id: event.id, circle_id: circle.id)
    genres.each_index do |idx|
      if idx == 0 then
        BookGenre.create(book_id: book.id, genre_id: genres[idx], is_main: true)
      else
        BookGenre.create(book_id: book.id, genre_id: genres[idx], is_main: false)
      end
    end
    authors.each_index do |idx|
      if idx == 0 then
        BookAuthor.create(book_id: book.id, author_id: authors[idx], is_main: true)
      else
        BookAuthor.create(book_id: book.id, author_id: authors[idx], is_main: false)
      end
    end
    tags.each_index do |idx|
      BookTag.create(book_id: book.id, tag_id: tags[idx])
    end
    # 所持状況更新
    UserBook.create(user_id: session[:id], book_id: book.id)
    redirect to('/user/mypage')
  end

  get '/book/:id/modify' do
    login_check
    @from = params["from"]
    @book = Book.includes(:authors, :genres, :tags, :event, :circle).find(params["id"])
    @book.authors.each_with_index do |obj, i|
      if i == 0 then
        @author = obj.name
      else
        @author += ","+obj.name
      end
    end
    @book.genres.each_with_index do |obj, i|
      if i == 0 then
        @genre = obj.name
      else
        @genre += ","+obj.name
      end
    end
    @book.tags.each_with_index do |obj, i|
      if i == 0 then
        @tag = obj.name
      else
        @tag += ","+obj.name
      end
    end
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
    
    # タグ
    tag_list = params["tag"].split(",")
    tags = []
    tag_list.each do |value|
      if value == "" then
        next
      end
      if Tag.exists?(name: value) then
        tag = Tag.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        tag = Tag.create(name: value, name_yomi: yomi)
      end
      tags.push(tag.id)
    end
    # ジャンル
    genre_list = params["genre"].split(",")
    genres = []
    genre_list.each do |value|
      if value == "" then
        next
      end
      if Genre.exists?(name: value) then
        genre = Genre.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        genre = Genre.create(name: value, name_yomi: yomi)
      end
      genres.push(genre.id)
    end
    # 著者
    author_list = params["author"].split(",")
    authors = []
    author_list.each do |value|
      if value == "" then
        next
      end
      if Author.exists?(name: value) then
        author = Author.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        author = Author.create(name: value, name_yomi: yomi)
      end
      authors.push(author.id)
    end
    # イベント
    if params["event"] != "" then
      if Event.exists?(name: params["event"]) then
        event = Event.find_by(name: params["event"])
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', params["event"])
        rescue => exception
          yomi = params["event"]
        end
        event = Event.create(name: params["event"], name_yomi: yomi)
      end
    end
    # サークル
    if Circle.exists?(name: params["circle"]) then
      circle = Circle.find_by(name: params["circle"])
    else
      begin
          yomi = Kakasi.kakasi('-JH -KH', params["circle"])
        rescue => exception
          yomi = params["circle"]
        end
      circle = Circle.create(name: params["circle"], name_yomi: yomi)
    end
    # 18禁
    is_adult = boolean_check(params["is-adult"])
    # 書籍登録
    # 順番に登録していく
    book = Book.find(params[:id]).update(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                                         mod_user: session[:id], event_id: event.id, circle_id: circle.id)
    BookGenre.where(book_id: params[:id]).delete_all
    BookAuthor.where(book_id: params[:id]).delete_all
    BookTag.where(book_id: params[:id]).delete_all
    genres.each_index do |idx|
      if idx == 0 then
        BookGenre.create(book_id: params[:id], genre_id: genres[idx], is_main: true)
      else
        BookGenre.create(book_id: params[:id], genre_id: genres[idx], is_main: false)
      end
    end
    authors.each_index do |idx|
      if idx == 0 then
        BookAuthor.create(book_id: params[:id], author_id: authors[idx], is_main: true)
      else
        BookAuthor.create(book_id: params[:id], author_id: authors[idx], is_main: false)
      end
    end
    tags.each_index do |idx|
      BookTag.create(book_id: params[:id], tag_id: tags[idx])
    end
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end
end