class AddUserToWasteLog < ActiveRecord::Migration[5.0]
  def change
    add_column :waste_logs, :user_id, :integer
    add_index :waste_logs, :user_id
    add_index :waste_logs, :store_id
    add_index :stores, :id
    add_index :stores, :rollout
  end
end
