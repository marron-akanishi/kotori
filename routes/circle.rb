class App < Sinatra::Base
  get '/circle' do
    @type_name = "サークル"
    @type = "circle"
    erb :list
  end
end