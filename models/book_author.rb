ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class BookAuthor < ActiveRecord::Base
  # 外部キー設定
  belongs_to :book
  belongs_to :author
end