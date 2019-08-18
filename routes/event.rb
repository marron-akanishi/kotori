class App < Sinatra::Base
  get '/event' do
    @type_name = "イベント"
    @type = "event"
    erb :list
  end

  get '/event/:id' do
    @type = "event"
    @type_name = "イベント"
    @detail = Event.find(params["id"])
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

  post '/event/:id/mod_yomi' do
    login_check
    begin
      Event.find(params["id"]).update(name_yomi: normalize_str(params["yomi"]))
    rescue => e
      redirect to("/error?code=422")
    end
    redirect to("/event/#{params["id"]}?msg=mod_yomi")
  end
end