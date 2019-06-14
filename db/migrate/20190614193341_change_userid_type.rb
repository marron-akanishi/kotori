class ChangeUseridType < ActiveRecord::Migration[5.2]
  def change
    change_column :owners, :user_id, :text
  end
end
