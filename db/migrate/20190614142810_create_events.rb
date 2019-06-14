class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.text :name
      t.date :start
      t.date :end
    end
  end
end
