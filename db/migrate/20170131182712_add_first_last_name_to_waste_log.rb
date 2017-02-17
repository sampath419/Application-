class AddFirstLastNameToWasteLog < ActiveRecord::Migration[5.0]
  def change
    add_column :waste_logs, :firstName, :string
    add_column :waste_logs, :lastName, :string
  end
end
