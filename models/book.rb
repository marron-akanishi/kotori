ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3'
)
class Book < ActiveRecord::Base
  has_many :owners
  belongs_to :genre
  belongs_to :author
  belongs_to :circle
  belongs_to :event
  belongs_to :user, foreign_key: :mod_user, primary_key: :id
end