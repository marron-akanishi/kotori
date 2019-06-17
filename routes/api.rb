class App < Sinatra::Base
  # 単純に全項目返す
  get '/api/get_list' do
    case params["type"]
      when "book" then
        Book.all.to_json
      when "author" then
        Author.all.to_json
      when "circle" then
        Circle.all.to_json
      when "event" then
        Event.all.to_json
      when "genre" then
        Genre.all.to_json
      when "ownlist" then
        login_check
        list = Book.where(id: Owner.where(user_id: session[:id]).select(:book_id))
        list.to_json
      else
        redirect to('/error?code=500')
    end
  end

  # 指定された情報に対応する書籍を返す(条件1つ)
  get '/api/find' do
    case params["type"]
      when "author" then
        Book.where(author_id: params["id"]).to_json
      when "circle" then
        Book.where(circle_id: params["id"]).to_json
      when "event" then
        Book.where(event_id: params["id"]).to_json
      when "genre" then
        Book.where(genre_id: params["id"]).to_json
      else
        redirect to('/error?code=500')
    end
  end

  # 指定された情報に対応する書籍を返す(条件複数)
  get '/api/search' do
  end
end