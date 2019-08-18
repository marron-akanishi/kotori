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
    message = {
      "mod_yomi" => "読みを修正しました"
    }
    @msg = message[params["msg"]]
    erb :detail
  end

  post '/tag/:id/mod_yomi' do
    login_check
    begin
      Tag.find(params["id"]).update(name_yomi: normalize_str(params["yomi"]))
    rescue => e
      redirect to("/error?code=422")
    end
    redirect to("/tag/#{params["id"]}?msg=mod_yomi")
  end
end