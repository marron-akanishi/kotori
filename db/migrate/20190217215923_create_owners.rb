class CreateOwners < ActiveRecord::Migration[5.2]
  def change
    create_table :owners do |t|
      t.references :user, foreign_key: true
      t.references :book, foreign_key: true
      t.text :memo
    end
  end
end
