ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3',
  :pool => 20
)
class Circle < ActiveRecord::Base 
  has_many :books
  has_many :users
  has_many :authors
end