ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class BookGenres < ActiveRecord::Base
  # 外部キー設定
  belongs_to :book
  belongs_to :genre
end