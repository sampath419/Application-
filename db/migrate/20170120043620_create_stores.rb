class CreateStores < ActiveRecord::Migration[5.0]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :rollout
      t.string :sales_org
      t.string :country
      t.string :city
      t.string :province

      t.timestamps
    end
  end
end
