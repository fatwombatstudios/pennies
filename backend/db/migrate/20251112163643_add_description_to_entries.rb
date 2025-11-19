class AddDescriptionToEntries < ActiveRecord::Migration[8.0]
  def change
    add_column :entries, :description, :text
  end
end
