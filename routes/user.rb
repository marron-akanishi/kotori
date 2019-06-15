class App < Sinatra::Base
  get '/user/mypage' do
    login_check
    @name = User.find(session[:id]).name
    erb :mypage
  end

  get '/user/setting' do
    login_check
    @name = User.find(session[:id]).name
    erb :setting
  end

  post '/user/setting/done' do
    login_check
    User.find(session[:id]).update(name: params["dispName"])
    redirect to('/user/mypage')
  end

  get '/user/own/:id' do
    login_check
    if !Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.create(user_id: session[:id], book_id: params["id"])
    end
    if boolean_check(params["exist"]) then
      redirect to('/book/'+params["id"]+'?from='+params["from"])
    else
      redirect to('/user/mypage')
    end
  end

  get '/user/unown/:id' do
    login_check
    if Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.where(user_id: session[:id], book_id: params["id"]).destroy_all
    end
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end

  post '/user/memo/:id' do
    login_check
    if Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.where(user_id: session[:id], book_id: params["id"]).update_all(memo: params["memoText"])
    end
    redirect to('/book/'+params["id"]+'?from='+params["from"])
  end
end