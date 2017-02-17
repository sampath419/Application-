class CreateWasteLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :waste_logs do |t|
      t.datetime :collection_date
      t.float :quantity
      t.boolean :is_active, default: true
      t.references :waste_type
      t.timestamps
    end
  end
end
