class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false do |t|
      t.text :id
      t.datetime :latest_at
      t.datetime :deleted_at
      t.text :name
    end
    add_index :users, :id, unique: true
  end
end
