ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class Book < ActiveRecord::Base
  # 外部キー設定
  has_many :users, through: :user_books
  has_many :user_books
  has_many :tags, through: :book_tags
  has_many :book_tags
  has_many :genres, through: :book_genres
  has_many :book_genres
  has_many :authors, through: :book_authors
  has_many :book_authors
  belongs_to :user, foreign_key:"mod_user"
  belongs_to :event
  belongs_to :circle
end