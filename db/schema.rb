# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_06_14_193341) do

  create_table "authors", force: :cascade do |t|
    t.text "name"
    t.text "detail"
    t.string "twitter"
    t.string "pixiv"
    t.text "web"
    t.integer "circle_id"
    t.index ["circle_id"], name: "index_authors_on_circle_id"
  end

  create_table "books", force: :cascade do |t|
    t.text "title"
    t.text "cover"
    t.date "date"
    t.text "detail"
    t.boolean "is_adult"
    t.integer "genre_id"
    t.integer "event_id"
    t.integer "author_id"
    t.integer "circle_id"
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["circle_id"], name: "index_books_on_circle_id"
    t.index ["event_id"], name: "index_books_on_event_id"
    t.index ["genre_id"], name: "index_books_on_genre_id"
  end

  create_table "circles", force: :cascade do |t|
    t.text "name"
    t.text "detail"
    t.text "web"
  end

  create_table "events", force: :cascade do |t|
    t.text "name"
    t.date "start"
    t.date "end"
  end

  create_table "genres", force: :cascade do |t|
    t.text "name"
  end

  create_table "owners", force: :cascade do |t|
    t.text "user_id"
    t.integer "book_id"
    t.boolean "is_read"
    t.text "memo"
    t.index ["book_id"], name: "index_owners_on_book_id"
    t.index ["user_id"], name: "index_owners_on_user_id"
  end

  create_table "users", id: false, force: :cascade do |t|
    t.text "id"
    t.datetime "latest_at"
    t.datetime "deleted_at"
    t.text "name"
    t.index ["id"], name: "index_users_on_id", unique: true
  end

end
