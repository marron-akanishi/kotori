ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class User < ActiveRecord::Base
  self.primary_key = :id
end