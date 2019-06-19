class CreateTables < ActiveRecord::Migration[5.2]
  def change
    create_table :users, id: false do |t|
      t.text :id, null: false
      t.text :mail, null: false
      t.datetime :latest_at, null: false
      t.datetime :deleted_at
      t.text :name, null: false
      t.boolean :is_adult, null: false
      t.references :circle, foreign_key: true
      t.references :author, foreign_key: true
      t.timestamps
    end
    add_index :users, :id, unique: true

    create_table :books do |t|
      t.text :title, null: false
      t.text :cover, null: false
      t.date :published_at
      t.text :detail
      t.boolean :is_adult, null: false
      t.text :mod_user, null: false
      t.references :circle, foreign_key: true, null: false
      t.references :event, foreign_key: true
      t.timestamps
    end
    add_foreign_key :books, :users, column: :mod_user

    create_table :tags do |t|
      t.text :name, null: false
      t.timestamps
    end

    create_table :genres do |t|
      t.text :name, null: false
      t.timestamps
    end

    create_table :authors do |t|
      t.text :name, null: false
      t.text :detail
      t.string :twitter
      t.string :pixiv
      t.text :web
      t.references :circle, foreign_key: true
      t.timestamps
    end

    create_table :events do |t|
      t.text :name, null: false
      t.date :start_at
      t.date :end_at
      t.timestamps
    end

    create_table :circles do |t|
      t.text :name, null: false
      t.text :detail
      t.text :web
      t.timestamps
    end
  end
end
