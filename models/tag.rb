ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3',
  :pool => 20
)
class Tag < ActiveRecord::Base
  # 外部キー設定
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags
end