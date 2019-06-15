class App < Sinatra::Base
  get '/event' do
    @type_name = "イベント"
    @type = "event"
    erb :list
  end
end