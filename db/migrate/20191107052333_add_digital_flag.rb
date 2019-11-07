class AddDigitalFlag < ActiveRecord::Migration[5.2]
  def change
    add_column :user_books, :is_digital, :boolean, default: false
  end
end
