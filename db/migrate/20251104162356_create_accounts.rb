class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.string :description
      t.string :account_type, null: false

      t.timestamps
    end
  end
end
