class App < Sinatra::Base
  get '/author' do
    @type_name = "著者"
    @type = "author"
    erb :list
  end
end