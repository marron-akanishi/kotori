require 'digest/md5'
require 'encryptor'
require 'securerandom'

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
      User.find(session[:id]).update(name: CGI.escapeHTML(params["dispName"]), is_adult: is_adult)
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
      redirect to("/book/#{params["id"]}?msg=own")
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
    redirect to("/book/#{params["id"]}?msg=unown")
  end

  post '/user/memo/:id' do
    login_check
    if UserBook.exists?(user_id: session[:id], book_id: params["id"]) then
      begin
        UserBook.where(user_id: session[:id], book_id: params["id"]).update(memo: CGI.escapeHTML(params["memoText"]))
      rescue => e
        redirect to("/error?code=512")
      end
    end
    redirect to("/book/#{params["id"]}?msg=memo")
  end

  get '/user/api_update' do
    login_check
    secret_key = SecureRandom.random_bytes(32)
    iv = SecureRandom.random_bytes(12)
    user = User.find(session[:id])
    key = Encryptor.encrypt(value: user.mail, key: secret_key, iv: iv)
    key = Digest::MD5.hexdigest(key)
    user.update(api: key)
    return key
  end

  post '/user/add_books' do
    login_check
    case params["mode"]
      when "melon" then
        @detail = SiteParser.melon(params["url"])
        if @detail == nil then
          return "error"
        end
      when "tora" then
        @detail = SiteParser.tora(params["url"])
        if @detail == nil then
          return "error"
        end
      when "lashin" then
        @detail = SiteParser.lashin(params["url"])
        if @detail == nil then
          return "error"
        end
      else
        return "error"
    end
    # タイトル存在チェック
    Book.all.each do |obj|
      if normalize_str(@detail[:title]) == normalize_str(obj.title) then
        return "duplicate"
      end
    end
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
    # 登録
    @detail = @detail.stringify_keys
    @detail["image-url"] = @detail["cover"]
    @detail["is-adult"] = @detail["is_adult"] ? "true" : "false"
    id = book_operate(@detail, false)
    if id == nil then
      return "error"
    end
    # 所持状況更新
    UserBook.create(user_id: session[:id], book_id: id)
    return "ok"
  end
end