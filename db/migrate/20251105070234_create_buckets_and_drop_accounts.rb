class CreateBucketsAndDropAccounts < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key "entries", "accounts", column: "credit_account_id"
    remove_foreign_key "entries", "accounts", column: "debit_account_id"

    create_table :buckets do |t|
      t.string :name, null: false
      t.string :description
      t.string :account_type, null: false

      t.timestamps
    end

    drop_table :accounts

    add_foreign_key "entries", "buckets", column: "credit_account_id"
    add_foreign_key "entries", "buckets", column: "debit_account_id"
  end
end
