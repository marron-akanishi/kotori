class App < Sinatra::Base
  get '/mypage' do
    login_check
    @name = User.find(session[:id]).name
    @list = []
    Owner.where(user_id: session[:id]).find_each do |book|
      @list << Book.find(book.book_id)
    end
    erb :mypage
  end

  get '/setting' do
    login_check
    @name = User.find(session[:id]).name
    erb :setting
  end

  post '/setting/done' do
    login_check
    User.find(session[:id]).update(name: params["dispName"])
    redirect to('/mypage')
  end

  get '/own/:id' do
    login_check
    if !Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.create(user_id: session[:id], book_id: params["id"])
    end
    if boolean_check(params["exist"]) then
      redirect to('/detail/book/'+params["id"]+'?from='+params["from"])
    else
      redirect to('/mypage')
    end
  end

  get '/unown/:id' do
    login_check
    if Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.where(user_id: session[:id], book_id: params["id"]).destroy_all
    end
    redirect to('/detail/book/'+params["id"]+'?from='+params["from"])
  end

  post '/memo/:id' do
    login_check
    if Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.where(user_id: session[:id], book_id: params["id"]).update_all(memo: params["memoText"])
    end
    redirect to('/detail/book/'+params["id"]+'?from='+params["from"])
  end
end