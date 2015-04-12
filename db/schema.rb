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

ActiveRecord::Schema.define(version: 20150412130946) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.string   "spotify_id"
    t.string   "spotify_access_token"
    t.string   "spotify_refresh_token"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "last_fm_username"
  end

  add_index "users", ["last_fm_username"], name: "index_users_on_last_fm_username", unique: true, where: "(spotify_id IS NULL)", using: :btree
  add_index "users", ["spotify_id", "last_fm_username"], name: "index_users_on_spotify_id_and_last_fm_username", unique: true, using: :btree
  add_index "users", ["spotify_id"], name: "index_users_on_spotify_id", unique: true, where: "(last_fm_username IS NULL)", using: :btree

  create_table "users_sessions", id: false, force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "session_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users_sessions", ["session_id"], name: "index_users_sessions_on_session_id", using: :btree
  add_index "users_sessions", ["user_id", "session_id"], name: "index_users_sessions_on_user_id_and_session_id", unique: true, using: :btree
  add_index "users_sessions", ["user_id"], name: "index_users_sessions_on_user_id", using: :btree

  add_foreign_key "users_sessions", "sessions"
  add_foreign_key "users_sessions", "users"
end
