ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class Owner < ActiveRecord::Base 
  belongs_to :user
  belongs_to :book
end