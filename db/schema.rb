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

ActiveRecord::Schema[8.0].define(version: 2025_11_04_164203) do
  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "account_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entries", force: :cascade do |t|
    t.datetime "date", null: false
    t.string "currency", null: false
    t.decimal "amount", null: false
    t.integer "debit_account_id", null: false
    t.integer "credit_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credit_account_id"], name: "index_entries_on_credit_account_id"
    t.index ["debit_account_id"], name: "index_entries_on_debit_account_id"
  end

  add_foreign_key "entries", "credit_accounts"
  add_foreign_key "entries", "debit_accounts"
end
