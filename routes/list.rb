class App < Sinatra::Base
  get '/list/:type' do
    case params["type"]
    when "book" then
      @type_name = "書籍"
    when "author" then
      @type_name = "著者"
    when "circle" then
      @type_name = "サークル"
    when "event" then
      @type_name = "頒布イベント"
    else
      redirect to('/error')
    end
    @type = params["type"]
    erb :list
  end
  
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
    else
      redirect to('/error')
    end
  end
end