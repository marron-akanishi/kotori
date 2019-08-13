# APIでBookのmod_userを連結したデータを返却しないこと！
# IDとメールアドレスが一緒に連結されてしまいます。

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
      when "book_author" then
        BookAuthor.all.to_json
      when "book_genre" then
        BookGenre.all.to_json
      when "circle" then
        Circle.all.to_json
      when "event" then
        Event.all.to_json
      when "tag" then
        Tag.all.to_json
      when "user_book" then
        login_check
        Book.includes(:authors, :genres, :tags, :event, :circle).where(id: UserBook.where(user_id: session[:id]).select(:book_id)).to_json(:include => [:authors, :genres, :tags, :event, :circle])
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
  get '/api/search' do
  end
end