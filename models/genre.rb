ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class Genre < ActiveRecord::Base
  has_many :book_genres, dependent: :destroy
  has_many :books, through: :book_genres
end