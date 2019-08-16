ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => 'db/db.sqlite3',
  :pool => 20
)
class Want < ActiveRecord::Base
  # 外部キー設定
  belongs_to :user
  belongs_to :book
end