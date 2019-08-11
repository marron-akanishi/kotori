ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class User < ActiveRecord::Base
  # 主キー設定
  self.primary_key = :id
  # 外部キー設定
  has_many :user_books, dependent: :destroy
  has_many :books, through: :user_books
  belongs_to :circle
  belongs_to :author
end