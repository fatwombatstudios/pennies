class AddSystemFlagToBuckets < ActiveRecord::Migration[8.0]
  def change
    add_column :buckets, :system, :boolean, default: false
  end
end
