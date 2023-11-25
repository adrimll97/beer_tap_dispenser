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

ActiveRecord::Schema[7.0].define(version: 2023_11_24_200953) do
  create_table "dispenser_usages", force: :cascade do |t|
    t.integer "dispenser_id", null: false
    t.datetime "opened_at", precision: nil, null: false
    t.datetime "closed_at", precision: nil
    t.float "total_spend"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "flow_volume", null: false
    t.float "price", null: false
    t.index ["dispenser_id"], name: "index_dispenser_usages_on_dispenser_id"
  end

  create_table "dispensers", force: :cascade do |t|
    t.float "flow_volume", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price", default: 12.25, null: false
    t.integer "status", default: 0, null: false
  end

  add_foreign_key "dispenser_usages", "dispensers"
end
