ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3',
  :pool => 20
)
class BookGenre < ActiveRecord::Base
  # 外部キー設定
  belongs_to :book
  belongs_to :genre
end