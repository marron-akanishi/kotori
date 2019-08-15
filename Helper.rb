require 'securerandom'
require 'open-uri'
require 'rmagick'

module Helper
  def login_check
    if session[:id] == nil then
      session[:redirect] = request.path
      redirect to('/?msg=login')
    end
  end

  def admin_check
    login_check
    if !User.find(session[:id]).is_admin then
      redirect to('/?msg=admin')
    end
  end

  def boolean_check(value)
    return value == 'true' ? true : false
  end

  def book_operate(params, is_mod)
    params["detail"] = ""
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
      value = CGI.escapeHTML(value)
      if Tag.exists?(name: value) then
        tag = Tag.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        begin
          tag = Tag.create(name: value, name_yomi: yomi)
        rescue => e
          redirect to("/error?code=512")
        end
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
      value = CGI.escapeHTML(value)
      if Genre.exists?(name: value) then
        genre = Genre.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        begin
          genre = Genre.create(name: value, name_yomi: yomi)
        rescue => e
          redirect to("/error?code=512")
        end
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
      value = CGI.escapeHTML(value)
      if Author.exists?(name: value) then
        author = Author.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        begin
          author = Author.create(name: value, name_yomi: yomi)
        rescue => e
          redirect to("/error?code=512")
        end
      end
      authors.push(author.id)
    end
    # イベント(必須ではない)
    if params["event"] != "" then
      value = CGI.escapeHTML(params["event"])
      if Event.exists?(name: value) then
        event = Event.find_by(name: value)
      else
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        begin
          event = Event.create(name: value, name_yomi: yomi)
        rescue => e
          redirect to("/error?code=512")
        end
      end
    end
    event_id = event == nil ? nil : event.id
    # サークル
    value = CGI.escapeHTML(params["circle"])
    if Circle.exists?(name: value) then
      circle = Circle.find_by(name: value)
    else
      begin
          yomi = Kakasi.kakasi('-JH -KH', value)
      rescue => exception
        yomi = value
      end
      begin
        circle = Circle.create(name: value, name_yomi: yomi)
      rescue => e
        redirect to("/error?code=512")
      end
    end
    # 18禁
    is_adult = boolean_check(params["is-adult"])
    # 書籍登録
    # 順番に登録していく
    if is_mod then
      begin
        book = Book.find(params[:id]).update(title: CGI.escapeHTML(params["title"]), cover: filename, published_at: CGI.escapeHTML(params["date"]), detail: CGI.escapeHTML(params["detail"]),
                                             is_adult: is_adult, mod_user: session[:id], event_id: event_id, circle_id: circle.id)
        BookGenre.where(book_id: params[:id]).delete_all
        BookAuthor.where(book_id: params[:id]).delete_all
        BookTag.where(book_id: params[:id]).delete_all
      rescue => e
        redirect to("/error?code=512")
      end
      book = Book.find(params[:id])
    else
      begin
        book = Book.create(title: CGI.escapeHTML(params["title"]), cover: filename, published_at: CGI.escapeHTML(params["date"]), detail: CGI.escapeHTML(params["detail"]),
                           is_adult: is_adult, mod_user: session[:id], event_id: event_id, circle_id: circle.id)
      rescue => e
        p e
        redirect to("/error?code=512")
      end
    end
    genres.each_index do |idx|
      begin
        if idx == 0 then
          BookGenre.create(book_id: book.id, genre_id: genres[idx], is_main: true)
        else
          BookGenre.create(book_id: book.id, genre_id: genres[idx], is_main: false)
        end
      rescue => e
        redirect to("/error?code=512")
      end
    end
    authors.each_index do |idx|
      begin
        if idx == 0 then
          BookAuthor.create(book_id: book.id, author_id: authors[idx], is_main: true)
        else
          BookAuthor.create(book_id: book.id, author_id: authors[idx], is_main: false)
        end
      rescue => e
        redirect to("/error?code=512")
      end
    end
    tags.each_index do |idx|
      begin
        BookTag.create(book_id: book.id, tag_id: tags[idx])
      rescue => e
        redirect to("/error?code=512")
      end
    end
    return book.id
  end
  
  module_function :login_check
  module_function :admin_check
  module_function :boolean_check
  module_function :book_operate
end