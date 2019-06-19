class App < Sinatra::Base
  get '/' do
    if session[:id] != nil then
      redirect to('/user/mypage')
    end
    erb :index
  end

  get '/error' do
    @msg = @@error_msg[params['code']]
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
      User.create(id: session[:id], name: name, mail: mail, latest_at: Time.now, is_adult: false)
    end
    redirect to('/user/mypage')
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end