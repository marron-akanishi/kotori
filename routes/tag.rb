class App < Sinatra::Base
  get '/tag' do
    @type = "tag"
    @type_name = "タグ"
    erb :list
  end

  get '/tag/:id' do
    @type = "tag"
    @type_name = "タグ"
    @detail = Tag.find(params["id"])
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    erb :detail
  end
end