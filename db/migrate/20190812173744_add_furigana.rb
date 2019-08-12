class AddFurigana < ActiveRecord::Migration[5.2]
  def change
    add_column :authors, :name_yomi, :text
    add_column :books, :name_yomi, :text
    add_column :circles, :name_yomi, :text
    add_column :events, :name_yomi, :text
    add_column :genres, :name_yomi, :text
    add_column :tags, :name_yomi, :text
  end
end
