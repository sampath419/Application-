class AddPilotFieldStore < ActiveRecord::Migration[5.0]
  def change
    add_column :stores, :pilot_enable, :boolean, default: true
  end
end
