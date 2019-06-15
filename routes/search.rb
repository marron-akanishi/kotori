class App < Sinatra::Base
  get '/search' do
    erb :search
  end
end