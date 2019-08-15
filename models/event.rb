ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3',
  :pool => 20
)
class Event < ActiveRecord::Base 
  has_many :books
end