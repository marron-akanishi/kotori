class App < Sinatra::Base
  get '/genre' do
    @type = "genre"
    @type_name = "ジャンル"
    erb :list
  end

  get '/genre/:id' do
    @type = "genre"
    @type_name = "ジャンル"
    @detail = Genre.find(params["id"])
    erb :detail
  end
end