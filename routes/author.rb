class App < Sinatra::Base
  get '/author' do
    @type = "author"
    @type_name = "著者"
    erb :list
  end

  get '/author/:id' do
    @type = "author"
    @type_name = "著者"
    @detail = Author.find(params["id"])
    erb :detail
  end
end