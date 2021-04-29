# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_07_052333) do

  create_table "authors", force: :cascade do |t|
    t.text "name", null: false
    t.text "detail"
    t.string "twitter"
    t.string "pixiv"
    t.text "web"
    t.integer "circle_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
    t.index ["circle_id"], name: "index_authors_on_circle_id"
  end

  create_table "book_authors", force: :cascade do |t|
    t.integer "book_id"
    t.integer "author_id"
    t.boolean "is_main"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
  end

  create_table "book_genres", force: :cascade do |t|
    t.integer "book_id"
    t.integer "genre_id"
    t.boolean "is_main"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_genres_on_book_id"
    t.index ["genre_id"], name: "index_book_genres_on_genre_id"
  end

  create_table "book_tags", force: :cascade do |t|
    t.integer "book_id"
    t.integer "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_tags_on_book_id"
    t.index ["tag_id"], name: "index_book_tags_on_tag_id"
  end

  create_table "books", force: :cascade do |t|
    t.text "title", null: false
    t.text "cover", null: false
    t.date "published_at"
    t.text "detail"
    t.boolean "is_adult", null: false
    t.text "mod_user", null: false
    t.integer "circle_id", null: false
    t.integer "event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
    t.text "url"
    t.index ["circle_id"], name: "index_books_on_circle_id"
    t.index ["event_id"], name: "index_books_on_event_id"
  end

  create_table "circles", force: :cascade do |t|
    t.text "name", null: false
    t.text "detail"
    t.text "web"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
  end

  create_table "events", force: :cascade do |t|
    t.text "name", null: false
    t.date "start_at"
    t.date "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
  end

  create_table "genres", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
  end

  create_table "tags", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name_yomi"
  end

  create_table "user_books", force: :cascade do |t|
    t.text "user_id"
    t.integer "book_id"
    t.boolean "is_read"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_digital", default: false
    t.index ["book_id"], name: "index_user_books_on_book_id"
    t.index ["user_id"], name: "index_user_books_on_user_id"
  end

  create_table "users", id: false, force: :cascade do |t|
    t.text "id", null: false
    t.text "mail", null: false
    t.datetime "latest_at", null: false
    t.datetime "deleted_at"
    t.text "name", null: false
    t.boolean "is_adult", null: false
    t.integer "circle_id"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.string "latest_ip"
    t.text "api"
    t.index ["api"], name: "index_users_on_api", unique: true
    t.index ["author_id"], name: "index_users_on_author_id"
    t.index ["circle_id"], name: "index_users_on_circle_id"
    t.index ["id"], name: "index_users_on_id", unique: true
  end

  create_table "wants", force: :cascade do |t|
    t.text "user_id"
    t.text "title"
    t.integer "book_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_wants_on_book_id"
  end

  add_foreign_key "authors", "circles"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_genres", "books"
  add_foreign_key "book_genres", "genres"
  add_foreign_key "book_tags", "books"
  add_foreign_key "book_tags", "tags"
  add_foreign_key "books", "circles"
  add_foreign_key "books", "events"
  add_foreign_key "books", "users", column: "mod_user"
  add_foreign_key "user_books", "books"
  add_foreign_key "user_books", "users"
  add_foreign_key "user_books", "users"
  add_foreign_key "users", "authors"
  add_foreign_key "users", "circles"
  add_foreign_key "wants", "books"
end
