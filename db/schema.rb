# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150504123118) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "last_fm_users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.boolean  "generated_playlist", default: false
  end

  create_table "spotify_users", force: :cascade do |t|
    t.string   "rspotify_hash"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users_sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.string   "spotify_id"
    t.string   "last_fm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users_sessions", ["session_id", "last_fm_id"], name: "index_users_sessions_on_session_id_and_last_fm_id", unique: true, using: :btree
  add_index "users_sessions", ["session_id", "spotify_id"], name: "index_users_sessions_on_session_id_and_spotify_id", unique: true, using: :btree

  add_foreign_key "users_sessions", "last_fm_users", column: "last_fm_id"
  add_foreign_key "users_sessions", "spotify_users", column: "spotify_id"
end
