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
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    erb :detail
  end
end