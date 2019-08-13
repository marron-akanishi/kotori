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
    erb :detail
  end
end