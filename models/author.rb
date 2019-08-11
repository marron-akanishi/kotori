ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class Author < ActiveRecord::Base 
  has_many :book_authors, dependent: :destroy
  has_many :books, through: :book_authors
  has_many :users
  belongs_to :circle
end