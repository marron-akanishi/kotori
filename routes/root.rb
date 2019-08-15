class App < Sinatra::Base
  get '/' do
    if session[:id] != nil then
      redirect to('/user/mypage')
    end
    message = {
      "login" => "ログインしてください",
      "admin" => "管理者のみアクセス可能です"
    }
    @msg = message[params['msg']]
    erb :index
  end

  get '/error' do
     message = {
      "403" => "ログインが禁止されています",
      "404" => "指定されたURLが見つかりません",
      "422" => "DBとの整合性チェックに失敗しました",
      "500" => "エラーが発生しました",
      "512" => "DBへの書き込みに失敗しました"
    }
    @error = message[params['code']]
    if @error == nil then
      @error = message["500"]
    end
    erb :error
  end

  get '/help' do
    erb :help
  end

  get '/login' do
    if request.referrer.index(@@env["DOMAIN"]) == 0 then
      session[:redirect] = request.referrer
    end
    redirect to('/auth/google_oauth2')
  end

  get "/auth/:provider/callback" do
    result = request.env["omniauth.auth"]
    session[:id] = result["uid"]
    if User.exists?(id: session[:id]) then
      if User.find(session[:id]).deleted_at != nil then
        session.clear
        redirect to('/error?code=403')
      end
      begin
        User.find(session[:id]).update(latest_at: Time.now)
      rescue => e
        redirect to("/error?code=512")
      end
    else
      name = result["info"]["name"]
      mail = result["info"]["email"]
      begin
        User.create(id: session[:id], name: CGI.escapeHTML(name), mail: mail, latest_at: Time.now, is_adult: false)
      rescue => e
        redirect to("/error?code=512")
      end
    end
    p session[:redirect]
    if session[:redirect] && session[:redirect].index(@@env["DOMAIN"]+"/error") != 0 then
      target = session[:redirect]
      session[:redirect] = nil
      redirect to(target)
    else
      redirect to('/user/mypage')
    end
  end

  get '/logout' do
    session.clear
    redirect to('/')
  end
end