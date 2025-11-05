class CreateBucketsAndDropAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :buckets do |t|
      t.string :name, null: false
      t.string :description
      t.string :account_type, null: false

      t.timestamps
    end

    drop_table :accounts
  end
end
