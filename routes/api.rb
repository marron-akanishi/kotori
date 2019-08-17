# APIでBookにuserをincludeしたデータを返却しないこと！
# mod_userのメールアドレスが入ります。

class App < Sinatra::Base
  # 単純に全項目返す
  get '/api/get_list' do
    case params["type"]
      when "book" then
        Book.all.to_json
      when "author" then
        Author.all.to_json
      when "genre" then
        Genre.all.to_json
      when "circle" then
        Circle.all.to_json
      when "event" then
        Event.all.to_json
      when "tag" then
        Tag.all.to_json
      when "user_book" then
        login_check
        UserBook.includes(book: [:authors, :genres, :circle])
                .where(user_id: session[:id])
                .to_json(include: {book: {include: [:authors, :genres, :circle]}})
      when "wishlist" then
        login_check
        Want.where(user_id: session[:id]).to_json()
      else
        redirect to('/error?code=500')
    end
  end

  # 指定されたIDに対応する書籍を返す
  get '/api/find' do
    case params["type"]
      when "genre" then
        if session[:id] == nil || !User.find(session[:id]).is_adult then
          Book.where(id: BookGenre.where(genre_id: params["id"]).select(:book_id), is_adult: false).to_json
        else
          Book.where(id: BookGenre.where(genre_id: params["id"]).select(:book_id)).to_json
        end
      when "author" then
        if session[:id] == nil || !User.find(session[:id]).is_adult then
          Book.where(id: BookAuthor.where(author_id: params["id"]).select(:book_id), is_adult: false).to_json
        else
          Book.where(id: BookAuthor.where(author_id: params["id"]).select(:book_id)).to_json
        end
      when "event" then
        if session[:id] == nil || !User.find(session[:id]).is_adult then
          Book.where(event_id: params["id"], is_adult: false).to_json
        else
          Book.where(event_id: params["id"]).to_json
        end
      when "circle" then
        if session[:id] == nil || !User.find(session[:id]).is_adult then
          Book.where(circle_id: params["id"], is_adult: false).to_json
        else
          Book.where(circle_id: params["id"]).to_json
        end
      when "tag" then
        if session[:id] == nil || !User.find(session[:id]).is_adult then
          Book.where(id: BookTag.where(tag_id: params["id"]).select(:book_id), is_adult: false).to_json
        else
          Book.where(id: BookTag.where(tag_id: params["id"]).select(:book_id)).to_json
        end
      else
        redirect to('/error?code=500')
    end
  end

  # 指定された情報に対応する書籍を返す(条件複数)
  post '/api/search' do
    # 書籍IDの一覧をそれぞれ作成して最後に合体させる
    # マイナス検索はそれぞれで行う
    words = params["words"].split(/[[:blank:]]+/)
    all_ids = Book.all.pluck(:id)
    # タイトル
    title_ids = []
    title_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        title_del |= Book.where('title like ?',"%#{CGI.escapeHTML(word)}%").pluck(:id)
      else
        title_ids |= Book.where('title like ?',"%#{CGI.escapeHTML(word)}%").pluck(:id)
      end
    end
    if title_ids.blank? && words.length != 1 then
      title_ids = all_ids
    end
    # 著者
    author_ids = []
    author_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        author_del |= BookAuthor.where(author_id: Author.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      else
        author_ids |= BookAuthor.where(author_id: Author.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      end
    end
    if author_ids.blank? && words.length != 1 then
      author_ids = all_ids
    end
    # サークル
    circle_ids = []
    circle_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        circle_del |= Book.where(circle_id: Circle.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:id)
      else
        circle_ids |= Book.where(circle_id: Circle.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:id)
      end
    end
    if circle_ids.blank? && words.length != 1 then
     circle_ids = all_ids
    end
    # ジャンル
    genre_ids = []
    genre_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        genre_del |= BookGenre.where(genre_id: Genre.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      else
        genre_ids |= BookGenre.where(genre_id: Genre.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      end
    end
    if genre_ids.blank? && words.length != 1 then
     genre_ids = all_ids
    end
    # イベント
    event_ids = []
    event_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        event_del |= Book.where(event_id: Event.where('name like ? or name_yomi like ?',
          "%#{CGI.escapeHTML(word)}%", "%#{normalize_str(word)}%")).pluck(:id)
      else
        event_ids |= Book.where(event_id: Event.where('name like ? or name_yomi like ?',
          "%#{CGI.escapeHTML(word)}%", "%#{normalize_str(word)}%")).pluck(:id)
      end
    end
    if event_ids.blank? && words.length != 1 then
     event_ids = all_ids
    end
    # タグ
    tag_ids = []
    tag_del = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        tag_del |= BookTag.where(tag_id: Tag.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      else
        tag_ids |= BookTag.where(tag_id: Tag.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      end
    end
    if tag_ids.blank? && words.length != 1 then
     tag_ids = all_ids
    end
    # 書籍
    if words.length == 1 then
      if words[0][0] == "-" then
        book_ids = all_ids - (title_del | author_del | circle_del | genre_del | event_del | tag_del)
      else
        book_ids = (title_ids | author_ids | circle_ids | genre_ids | event_ids | tag_ids)
      end 
    else
      book_ids = (title_ids & author_ids & circle_ids & genre_ids & event_ids & tag_ids) - (title_del | author_del | circle_del | genre_del | event_del | tag_del)
    end
    if params["words"] != "" && book_ids.length == all_ids.length then
      "[]"
    else
      Book.includes(:authors, :circle).where(id: book_ids).to_json(include: [:authors, :circle])
    end
  end

  # APIキーを利用した所有書籍の取得
  get '/api/get_booklist' do
    if params["key"] == nil || !User.exists?(api: params["key"]) then
      return "error"
    else
      user_id = User.find_by(api: params["key"]).id
      Book.where(id: UserBook.where(user_id: user_id).select(:book_id)).to_json()
    end
  end
end