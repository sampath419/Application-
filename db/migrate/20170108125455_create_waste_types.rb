class CreateWasteTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :waste_types do |t|
      t.string :name
      t.string :title
      t.timestamps
    end
  end
end
