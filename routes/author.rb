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

  post '/author/mod_yomi' do
    begin
      Author.find(params["id"]).update(name_yomi: normalize_str(params["yomi"]))
    rescue => e
      redirect to("/error?code=422")
    end
    redirect to("/author/#{params["id"]}")
  end
end