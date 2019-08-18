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
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    erb :detail
  end
end