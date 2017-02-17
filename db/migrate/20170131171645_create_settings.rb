class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.integer :user_id
      t.integer :measurement_type_id
      t.integer :store_id
      t.timestamps
    end
  end
end
