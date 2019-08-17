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
    words = params["words"].split(/[[:blank:]]+/)
    all_ids = Book.all.pluck(:id)
    book_ids = all_ids
    delete_ids = []
    words.each do |word|
      if word == "" then
        next
      end
      if word[0] == "-" then
        word = word[1..-1]
        delete_ids |= Book.where('title like ?',"%#{CGI.escapeHTML(word)}%").pluck(:id)
        delete_ids |= BookAuthor.where(author_id: Author.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
        delete_ids |= Book.where(circle_id: Circle.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:id)
        delete_ids |= BookGenre.where(genre_id: Genre.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
        delete_ids |= Book.where(event_id: Event.where('name like ? or name_yomi like ?',
          "%#{CGI.escapeHTML(word)}%", "%#{normalize_str(word)}%")).pluck(:id)
        delete_ids |= BookTag.where(tag_id: Tag.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
      else
        find_ids = []
        find_ids |= Book.where('title like ?',"%#{CGI.escapeHTML(word)}%").pluck(:id)
        find_ids |= BookAuthor.where(author_id: Author.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
        find_ids |= Book.where(circle_id: Circle.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:id)
        find_ids |= BookGenre.where(genre_id: Genre.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
        find_ids |= Book.where(event_id: Event.where('name like ? or name_yomi like ?',
          "%#{CGI.escapeHTML(word)}%", "%#{normalize_str(word)}%")).pluck(:id)
        find_ids |= BookTag.where(tag_id: Tag.where('name like ? or name_yomi like ?',
          "#{CGI.escapeHTML(word)}%", "#{normalize_str(word)}%")).pluck(:book_id)
        book_ids &= find_ids
      end
    end
    book_ids = book_ids - delete_ids
    Book.includes(:authors, :circle).where(id: book_ids).to_json(include: [:authors, :circle])
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