class BookAuthor < ActiveRecord::Base
  # 外部キー設定
  belongs_to :book
  belongs_to :author
end