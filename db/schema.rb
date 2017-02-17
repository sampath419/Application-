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

ActiveRecord::Schema.define(version: 20170131182712) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "ratting"
    t.text     "content"
    t.string   "store_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurement_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "measurement_type_id"
    t.integer  "store_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "stores", force: :cascade do |t|
    t.string   "name"
    t.string   "rollout"
    t.string   "sales_org"
    t.string   "country"
    t.string   "city"
    t.string   "province"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "pilot_enable", default: true
    t.index ["id"], name: "index_stores_on_id", using: :btree
    t.index ["rollout"], name: "index_stores_on_rollout", using: :btree
  end

  create_table "waste_logs", force: :cascade do |t|
    t.datetime "collection_date"
    t.float    "quantity"
    t.boolean  "is_active",           default: true
    t.integer  "waste_type_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "store_id"
    t.integer  "measurement_type_id"
    t.integer  "user_id"
    t.string   "firstName"
    t.string   "lastName"
    t.index ["measurement_type_id"], name: "index_waste_logs_on_measurement_type_id", using: :btree
    t.index ["store_id"], name: "index_waste_logs_on_store_id", using: :btree
    t.index ["user_id"], name: "index_waste_logs_on_user_id", using: :btree
    t.index ["waste_type_id"], name: "index_waste_logs_on_waste_type_id", using: :btree
  end

  create_table "waste_types", force: :cascade do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
