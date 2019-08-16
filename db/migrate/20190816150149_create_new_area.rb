class CreateNewArea < ActiveRecord::Migration[5.2]
  def change
    create_table :wants do |t|
      t.text :user_id
      t.text :title
      t.references :book, foreign_key: true
      t.timestamps
    end
    add_foreign_key :user_books, :users

    add_column :books, :url, :text
    add_column :users, :latest_ip, :string
    add_column :users, :api, :text
    add_index :users, :api, unique: true
  end
end
