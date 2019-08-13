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
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    erb :detail
  end
end