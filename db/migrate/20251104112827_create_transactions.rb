class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.datetime :date, null: false
      t.decimal :amount, null: false
      t.string :currency, null: false
      t.string :description

      t.timestamps
    end
  end
end
