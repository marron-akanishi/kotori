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
    message = {
      "mod_yomi" => "読みを修正しました"
    }
    @msg = message[params["msg"]]
    erb :detail
  end

  post '/genre/:id/mod_yomi' do
    login_check
    begin
      Genre.find(params["id"]).update(name_yomi: normalize_str(params["yomi"]))
    rescue => e
      redirect to("/error?code=422")
    end
    redirect to("/genre/#{params["id"]}?msg=mod_yomi")
  end
end