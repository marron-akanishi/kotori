class App < Sinatra::Base
  get '/book/:id' do
    @from = params["from"]
    @book = Book.includes(:authors, :genres, :tags, :user, :event, :circle).find(params["id"])
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    if session[:id] != nil && UserBook.exists?(user_id: session[:id], book_id: params["id"])then
      @owned = true;
      @is_adult = true;
      @memo = UserBook.find_by(user_id: session[:id], book_id: params["id"]).memo
    end
    message = {
      "own" => "書籍を所有状態にしました",
      "unown" => "書籍を未所有状態にしました",
      "memo" => "メモを保存しました",
      "modify" => "書籍情報を保存しました"
    }
    @msg = message[params["msg"]]
    erb :book_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  get '/book/add/title' do
    login_check
    erb :book_add_title, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  post '/book/add/detail' do
    login_check
    case params["mode"]
      when "manual" then
        @detail = {}
        @title = params["title"]
      when "melon" then
        @detail = SiteParser.melon(params["url"])
        @title = @detail[:title]
      when "tora" then
        @detail = SiteParser.tora(params["url"])
        @title = @detail[:title]
      when "lashin" then
        @detail = SiteParser.lashin(params["url"])
        @title = @detail[:title]
    end
    @exists = []
    # タイトル存在チェック
    Book.all.each do |obj|
      # カナ→ひら、半角化、スペース削除、大文字小文字無視
      target = @title.tr('ァ-ン','ぁ-ん')
      check = obj.title.tr('ァ-ン','ぁ-ん')
      target = target.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
      check = check.tr('０-９ａ-ｚＡ-Ｚ','0-9a-zA-Z')
      target = target.gsub(/(\s|　)+/, '')
      check = check.gsub(/(\s|　)+/, '')
      if target.upcase == check.upcase then
        @exists.push(Book.includes(:authors).find(obj.id))
      end
    end
    erb :book_add_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  post '/book/add/done' do
    login_check
    id = book_operate(params, false)
    # 所持状況更新
    UserBook.create(user_id: session[:id], book_id: id)
    redirect to('/user/mypage?msg=add_done')
  end

  get '/book/:id/modify' do
    login_check
    @from = params["from"]
    @book = Book.includes(:authors, :genres, :tags, :event, :circle).find(params["id"])
    @book.authors.each_with_index do |obj, i|
      if i == 0 then
        @author = obj.name
      else
        @author += ","+obj.name
      end
    end
    @book.genres.each_with_index do |obj, i|
      if i == 0 then
        @genre = obj.name
      else
        @genre += ","+obj.name
      end
    end
    @book.tags.each_with_index do |obj, i|
      if i == 0 then
        @tag = obj.name
      else
        @tag += ","+obj.name
      end
    end
    erb :book_modify, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  post '/book/:id/modify/done' do
    login_check
    book_operate(params, true)
    redirect to("/book/#{params["id"]}?from=#{params["from"]}&msg=modify")
  end
end