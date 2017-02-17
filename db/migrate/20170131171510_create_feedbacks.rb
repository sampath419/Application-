class CreateFeedbacks < ActiveRecord::Migration[5.0]
  def change
    create_table :feedbacks do |t|
      t.integer :user_id
      t.integer :ratting
      t.text :content
      t.string :store_id
      t.timestamps
    end
  end
end
