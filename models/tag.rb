class Tag < ActiveRecord::Base
  # 外部キー設定
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags
end