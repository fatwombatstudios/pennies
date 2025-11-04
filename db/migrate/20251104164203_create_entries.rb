class CreateEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :entries do |t|
      t.datetime :date, null: false
      t.string :currency, null: false
      t.decimal :amount, null: false
      t.references :debit_account, null: false, foreign_key: true
      t.references :credit_account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
