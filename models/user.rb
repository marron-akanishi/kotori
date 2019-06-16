ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class User < ActiveRecord::Base
  self.primary_key = :id
  has_many :owners
  has_many :books, foreign_key: :id, primary_key: :mod_user
end