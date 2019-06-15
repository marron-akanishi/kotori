class App < Sinatra::Base
  get '/' do
    if session[:id] != nil then
      redirect to('/mypage')
    end
    erb :index
  end

  get '/error' do
    erb :error
  end

  get '/help' do
    erb :help
  end

  get "/auth/:provider/callback" do
    result = request.env["omniauth.auth"]
    session[:id] = result["uid"]
    if User.exists?(id: session[:id]) then
      User.find(session[:id]).update(latest_at: Time.now)
    else
      name = result["info"]["name"]
      mail = result["info"]["email"]
      User.create(id: session[:id], name: name, mail: mail, latest_at: Time.now)
    end
    redirect to('/mypage')
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end