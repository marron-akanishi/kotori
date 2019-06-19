class App < Sinatra::Base
  get '/user/mypage' do
    login_check
    @name = User.find(session[:id]).name
    erb :mypage
  end

  get '/user/setting' do
    login_check
    @user = User.find(session[:id])
    @isAdmin = (User.find(session[:id]).mail == @@env["ADMIN_EMAIL"])
    erb :setting
  end

  post '/user/setting/done' do
    login_check
    User.find(session[:id]).update(name: params["dispName"])
    redirect to('/user/mypage')
  end

  get '/user/own/:id' do
    login_check
    if !UserBooks.exists?(user_id: session[:id], book_id: params["id"]) then
      UserBooks.create(user_id: session[:id], book_id: params["id"])
    end
    if boolean_check(params["exist"]) then
      redirect to('/book/'+params["id"]+'?from='+params["from"])
    else
      redirect to('/user/mypage')
    end
  end

  get '/user/unown/:id' do
    login_check
    if UserBooks.exists?(user_id: session[:id], book_id: params["id"]) then
      UserBooks.find_by(user_id: session[:id], book_id: params["id"]).destroy
    end
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end

  post '/user/memo/:id' do
    login_check
    if UserBooks.exists?(user_id: session[:id], book_id: params["id"]) then
      UserBooks.where(user_id: session[:id], book_id: params["id"]).update(memo: params["memoText"])
    end
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end
end