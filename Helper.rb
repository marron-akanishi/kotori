require 'securerandom'
require 'open-uri'
require 'rmagick'

module Helper
  def login_check
    if session[:id] == nil then
      redirect to('/')
    end
  end

  def admin_check
    login_check
    if !User.find(session[:id]).is_admin then
      redirect to('/')
    end
  end

  def boolean_check(value)
    return value == 'true' ? true : false
  end

  def book_operate(params, is_mod)
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
    elsif params["image-url"] != "" && is_mod == false then
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
      if is_mod then
        filename = params["orig-cover"]
      else
        filename = "noimage.png"
      end
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
    if is_mod then
      book = Book.find(params[:id]).update(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                                         mod_user: session[:id], event_id: event.id, circle_id: circle.id)
      BookGenre.where(book_id: params[:id]).delete_all
      BookAuthor.where(book_id: params[:id]).delete_all
      BookTag.where(book_id: params[:id]).delete_all
      book = Book.find(params[:id])
    else
      book = Book.create(title: params["title"], cover: filename, published_at: params["date"], detail: params["detail"], is_adult: is_adult,
                          mod_user: session[:id], event_id: event.id, circle_id: circle.id)
    end
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
    return book.id
  end
  
  module_function :login_check
  module_function :admin_check
  module_function :boolean_check
  module_function :book_operate
end