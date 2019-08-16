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

  # カナ→ひら、半角化、スペース削除、大文字化
  # 読みの場合は!と?も削除する
  def normalize_str(str, is_yomi=false)
    str = str.tr('ァ-ン','ぁ-ん')
    str = str.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
    str = str.gsub(/(\s|　)+/, '')
    if is_yomi then
      str = str.delete('!！?？')
    end
    return str.upcase
  end

  def book_operate(params, is_mod)
    params["detail"] = ""
    # 表紙画像保存
    if params["cover-img"] != nil then
      filename = SecureRandom.uuid + ".jpg"
      begin
        image = Magick::Image.read(params["cover-img"]["tempfile"].path)[0]
      rescue => exception
        return nil
      end
      if !["BMP","JPEG","PNG"].include?(image.format) then
        return nil
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
        return nil
      end
      if !["BMP","JPEG","PNG"].include?(image.format) then
        return nil
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
    
    begin
      # DB保存
      # タグ(オプション)
      if params["tag"] != nil then
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
            tag = Tag.create(name: value, name_yomi: normalize_str(yomi, true))
          end
          tags.push(tag.id)
        end
      end
      # ジャンル(必須)
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
          genre = Genre.create(name: value, name_yomi: normalize_str(yomi, true))
        end
        genres.push(genre.id)
      end
      # 著者(必須)
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
          author = Author.create(name: value, name_yomi: normalize_str(yomi, true))
        end
        authors.push(author.id)
      end
      # イベント(オプション)
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
          event = Event.create(name: value, name_yomi: normalize_str(yomi, true))
        end
      end
      event_id = event == nil ? nil : event.id
      # サークル(必須)
      value = CGI.escapeHTML(params["circle"])
      if Circle.exists?(name: value) then
        circle = Circle.find_by(name: value)
      else
        begin
            yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        circle = Circle.create(name: value, name_yomi: normalize_str(yomi, true))
      end
      # 18禁
      is_adult = boolean_check(params["is-adult"])
      # 書籍登録
      # 順番に登録していく
      if is_mod then
        book = Book.find(params[:id]).update(title: CGI.escapeHTML(params["title"]), cover: filename, published_at: CGI.escapeHTML(params["date"]), detail: CGI.escapeHTML(params["detail"]),
                                            is_adult: is_adult, mod_user: session[:id], event_id: event_id, circle_id: circle.id, url: CGI.escapeHTML(params["url"]))
        BookGenre.where(book_id: params[:id]).delete_all
        BookAuthor.where(book_id: params[:id]).delete_all
        BookTag.where(book_id: params[:id]).delete_all
        book = Book.find(params[:id])
      else
        book = Book.create(title: CGI.escapeHTML(params["title"]), cover: filename, published_at: CGI.escapeHTML(params["date"]), detail: CGI.escapeHTML(params["detail"]),
                          is_adult: is_adult, mod_user: session[:id], event_id: event_id, circle_id: circle.id, url: CGI.escapeHTML(params["url"]))
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
      if tags != nil then
        tags.each_index do |idx|
          BookTag.create(book_id: book.id, tag_id: tags[idx])
        end
      end
      return book.id
    rescue => e
      return nil
    end
  end
  
  module_function :login_check
  module_function :admin_check
  module_function :boolean_check
  module_function :book_operate
end