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
    message = {
      "mod_yomi" => "読みを修正しました"
    }
    @msg = message[params["msg"]]
    erb :detail
  end

  post '/circle/:id/mod_yomi' do
    login_check
    begin
      Circle.find(params["id"]).update(name_yomi: normalize_str(params["yomi"]))
    rescue => e
      redirect to("/error?code=422")
    end
    redirect to("/circle/#{params["id"]}?msg=mod_yomi")
  end
end