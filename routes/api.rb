class App < Sinatra::Base
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
        @list = []
        Owner.where(user_id: session[:id]).find_each do |book|
          @list << Book.find(book.book_id)
        end
        @list.to_json
      else
        redirect to('/error?code=500')
    end
  end
end