class App < Sinatra::Base
  get '/book/search' do
    erb :book_search, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  get '/book/:id' do
    @book = Book.includes(:authors, :genres, :tags, :user, :event, :circle).find(params["id"])
    if session[:id] == nil then
      @is_adult = false
    else
      @is_adult = User.find(session[:id]).is_adult
    end
    if session[:id] != nil then
      if UserBook.exists?(user_id: session[:id], book_id: params["id"]) then
        @owned = true;
        @is_adult = true;
        @memo = UserBook.find_by(user_id: session[:id], book_id: params["id"]).memo
      else
        @owned = false;
        @is_want = Want.exists?(user_id: session[:id], book_id: params["id"])
      end
    end
    message = {
      "own" => "書籍を所有状態にしました",
      "unown" => "書籍を未所有状態にしました",
      "memo" => "メモを保存しました",
      "modify" => "書籍情報を保存しました",
      "wishlist_add" => "ほしい物リストに追加しました",
      "wishlist_max" => "ほしい物リストが50件を超えるため、追加できません"
    }
    @msg = message[params["msg"]]
    # パンくずリスト用にアクセス元を保存
    if request.referrer != nil && request.referrer.index(@@env["DOMAIN"]) then
      prev = request.referrer.split('/')
      # マイページorほしい物リストor詳細画面のみに絞る
      if prev[4] == "mypage" || prev[4] == "wishlist" || (prev[3] != "book" && prev[4] =~ /\A[0-9]+\z/)  then
        session[:prev_type] = prev[3]
        session[:prev_detail] = prev[4]
      else
        session[:prev_type] = nil
        session[:prev_id] = nil
      end
    else
      session[:prev_type] = nil
      session[:prev_id] = nil
    end
    @type = @@type_list[session[:prev_type]]
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
        if @detail == nil then
          redirect to("/error?code=404")
        end
        @title = @detail[:title]
      when "tora" then
        @detail = SiteParser.tora(params["url"])
        if @detail == nil then
          redirect to("/error?code=404")
        end
        @title = @detail[:title]
      when "lashin" then
        @detail = SiteParser.lashin(params["url"])
        if @detail == nil then
          redirect to("/error?code=404")
        end
        @title = @detail[:title]
    end
    if @detail[:title] != nil then
      # 著者存在チェック
      author_list = @detail[:author].split(",")
      author_list.each do |value|
        if value == "" then
          next
        end
        value = CGI.escapeHTML(value)
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        if Author.exists?(name_yomi: normalize_str(yomi, true)) then
          name = Author.find_by(name_yomi: normalize_str(yomi, true)).name
          @detail[:author].gsub(value, name)
        end
      end
      # サークル存在チェック
      value = CGI.escapeHTML(@detail[:circle])
      begin
          yomi = Kakasi.kakasi('-JH -KH', value)
      rescue => exception
        yomi = value
      end
      if Circle.exists?(name_yomi: normalize_str(yomi, true)) then
        name = Circle.find_by(name_yomi: normalize_str(yomi, true)).name
        @detail[:circle] = name
      end
      # ジャンル存在チェック
      genre_list = @detail[:genre].split(",")
      genre_list.each do |value|
        if value == "" then
          next
        end
        value = CGI.escapeHTML(value)
        begin
          yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        if Genre.exists?(name_yomi: normalize_str(yomi, true)) then
          name = Genre.find_by(name_yomi: normalize_str(yomi, true)).name
          @detail[:genre].gsub(value, name)
        end
      end
      # イベント存在チェック
      if @detail[:event] != nil then
        value = CGI.escapeHTML(@detail[:event])
        begin
            yomi = Kakasi.kakasi('-JH -KH', value)
        rescue => exception
          yomi = value
        end
        if Circle.exists?(name_yomi: normalize_str(yomi, true)) then
          name = Circle.find_by(name_yomi: normalize_str(yomi, true)).name
          @detail[:circle] = name
        end
      end
      # タグ存在チェック
      if @detail[:tag] != nil then
        tag_list = @detail[:tag].split(",")
        tag_list.each do |value|
          if value == "" then
            next
          end
          value = CGI.escapeHTML(value)
          begin
            yomi = Kakasi.kakasi('-JH -KH', value)
          rescue => exception
            yomi = value
          end
          if Tag.exists?(name_yomi: normalize_str(yomi, true)) then
            name = Tag.find_by(name_yomi: normalize_str(yomi, true)).name
            @detail[:tag].gsub(value, name)
          end
        end
      end
    end
    @exists = []
    # タイトル存在チェック
    Book.all.each do |obj|
      if normalize_str(@title) == normalize_str(obj.title) then
        @exists.push(Book.includes(:authors).find(obj.id))
      end
    end
    erb :book_add_detail, :layout_options => { :views => settings.views }, :views => settings.views + '/book'
  end

  post '/book/add/done' do
    login_check
    id = book_operate(params, false)
    if id == nil then
      redirect to('/error?code=512')
    end
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
    id = book_operate(params, true)
    if id == nil then
      redirect to('/error?code=512')
    end
    redirect to("/book/#{id}?msg=modify")
  end
end