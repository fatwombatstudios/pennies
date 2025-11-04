class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.datetime :date, null: false
      t.string :currency, null: false
      t.decimal :amount, null: false
      t.integer :debit_account_id, null: false
      t.integer :credit_account_id, null: false

      t.timestamps
    end

    add_foreign_key :entries, :accounts, column: :debit_account_id
    add_foreign_key :entries, :accounts, column: :credit_account_id
  end
end
