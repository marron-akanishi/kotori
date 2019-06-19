class CreateJunctionTables < ActiveRecord::Migration[5.2]
  def change
    create_table :user_books do |t|
      t.text :user_id, index: true
      t.references :book, index: true, foreign_key: true
      t.boolean :is_read
      t.text :memo
      t.timestamps
    end
    add_foreign_key :user_books, :users

    create_table :book_tags do |t|
      t.references :book,  index: true, foreign_key: true
      t.references :tag,  index: true, foreign_key: true
      t.timestamps
    end

    create_table :book_genres do |t|
      t.references :book,  index: true, foreign_key: true
      t.references :genre,  index: true, foreign_key: true
      t.boolean :is_main
      t.timestamps
    end

    create_table :book_authors do |t|
      t.references :book,  index: true, foreign_key: true
      t.references :author,  index: true, foreign_key: true
      t.boolean :is_main
      t.timestamps
    end
  end
end
