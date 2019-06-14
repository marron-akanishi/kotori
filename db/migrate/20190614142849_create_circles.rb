class CreateCircles < ActiveRecord::Migration[5.2]
  def change
    create_table :circles do |t|
      t.text :name
      t.text :detail
      t.text :web
    end
  end
end
