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

ActiveRecord::Schema.define(version: 20190620014243) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "remembered_words", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "word_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_remembered_words_on_user_id"
    t.index ["word_id"], name: "index_remembered_words_on_word_id"
  end

  create_table "sentences", force: :cascade do |t|
    t.bigint "word_id"
    t.string "chinese", null: false
    t.string "japanese", null: false
    t.string "pinyin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_id"], name: "index_sentences_on_word_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "widgets", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "stock"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "words", force: :cascade do |t|
    t.string "chinese", null: false
    t.string "japanese", null: false
    t.string "pinyin", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level"
  end

  add_foreign_key "remembered_words", "users"
  add_foreign_key "remembered_words", "words"
  add_foreign_key "sentences", "words"
end
