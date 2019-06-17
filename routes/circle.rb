class App < Sinatra::Base
  get '/circle' do
    @type_name = "サークル"
    @type = "circle"
    erb :list
  end

  get '/circle/:id' do
    @type = "circle"
    @type_name = "サークル"
    @detail = Circle.find(params["id"])
    erb :detail
  end
end