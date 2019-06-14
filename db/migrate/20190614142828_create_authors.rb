class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.text :name
      t.text :detail
      t.string :twitter
      t.string :pixiv
      t.text :web
      t.references :circle, foreign_key: true
    end
  end
end
