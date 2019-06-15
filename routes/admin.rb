class App < Sinatra::Base
  get '/admin' do
  end

  get '/admin/setting' do
  end

  post '/admin/setting/done' do
  end

  get '/admin/status' do
  end

  get '/admin/user' do
  end

  post '/admin/user/:id/circle' do
  end
  
  get '/admin/user/:id/quit' do
  end

  get '/admin/book' do
  end

  get '/admin/book/:id/delete' do
  end

  get '/admin/author' do
  end

  get '/admin/author/:id/modify' do
  end

  get '/admin/author/:id/delete' do
  end

  get '/admin/circle' do
  end

  get '/admin/circle/:id/modify' do
  end

  get '/admin/circle/:id/delete' do
  end

  get '/admin/event' do
  end

  get '/admin/event/:id/modify' do
  end

  get '/admin/event/:id/delete' do
  end
end