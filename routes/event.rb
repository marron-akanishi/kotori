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
    erb :detail
  end
end