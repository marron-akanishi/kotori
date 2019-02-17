class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table(:users, :id => false) do |t|
      t.string :id
      t.datetime :latest_at
      t.datetime :deleted_at
      t.string :name
    end
  end
end
