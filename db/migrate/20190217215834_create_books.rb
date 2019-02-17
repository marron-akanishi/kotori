class CreateBooks < ActiveRecord::Migration[5.2]
  def change
    create_table :books do |t|
      t.text :title
      t.text :cover
      t.date :date
      t.references :event, foreign_key: true
      t.references :author, foreign_key: true
      t.references :circle, foreign_key: true
    end
  end
end
