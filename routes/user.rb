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
  end

  post '/setting/done' do
    login_check
  end

  get '/own/:id' do
    login_check
    if !Owner.exists?(user_id: session[:id], book_id: params["id"]) then
      Owner.create(user_id: session[:id], book_id: params["id"])
    end
    redirest to('/mypage')
  end
end