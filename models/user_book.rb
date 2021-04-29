class UserBook < ActiveRecord::Base
  # 外部キー設定
  belongs_to :user
  belongs_to :book
end