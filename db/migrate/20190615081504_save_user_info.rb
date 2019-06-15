class SaveUserInfo < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mail, :text
    add_column :books, :mod_user, :text
  end
end
