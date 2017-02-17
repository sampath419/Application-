class AddStoreToWasteLog < ActiveRecord::Migration[5.0]
  def change
    add_column :waste_logs, :store_id, :string
    add_reference :waste_logs, :measurement_type, index: true
  end
end
