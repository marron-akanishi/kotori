class App < Sinatra::Base
  get '/user/mypage' do
    login_check
    @name = User.find(session[:id]).name
    message = {
      "add_done" => "書籍を追加しました",
      "setting_done" => "設定を保存しました"
    }
    @msg = message[params["msg"]]
    erb :mypage
  end

  get '/user/setting' do
    login_check
    @user = User.find(session[:id])
    erb :setting
  end

  post '/user/setting/done' do
    login_check
    is_adult = boolean_check(params["is-adult"])
    begin
      User.find(session[:id]).update(name: params["dispName"], is_adult: is_adult)
    rescue => e
      redirect to("/error?code=512")
    end
    redirect to('/user/mypage?msg=setting_done')
  end

  get '/user/own/:id' do
    login_check
    if !UserBook.exists?(user_id: session[:id], book_id: params["id"]) then
      begin
        UserBook.create(user_id: session[:id], book_id: params["id"])
      rescue => e
        redirect to("/error?code=512")
      end
    end
    if boolean_check(params["exist"]) then
      redirect to("/book/#{params["id"]}?from=#{params["from"]}&msg=own")
    else
      redirect to('/user/mypage?msg=add_done')
    end
  end

  get '/user/unown/:id' do
    login_check
    if UserBook.exists?(user_id: session[:id], book_id: params["id"]) then
      begin
        UserBook.find_by(user_id: session[:id], book_id: params["id"]).destroy
      rescue => e
        redirect to("/error?code=512")
      end
    end
    redirect to("/book/#{params["id"]}?from=#{params["from"]}&msg=unown")
  end

  post '/user/memo/:id' do
    login_check
    if UserBook.exists?(user_id: session[:id], book_id: params["id"]) then
      begin
        UserBook.where(user_id: session[:id], book_id: params["id"]).update(memo: params["memoText"])
      rescue => e
        redirect to("/error?code=512")
      end
    end
    redirect to("/book/#{params["id"]}?from=#{params["from"]}&msg=memo")
  end

  post '/user/add_book' do
  end
end