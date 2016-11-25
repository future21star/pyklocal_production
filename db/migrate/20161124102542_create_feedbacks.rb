class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string :name
      t.text :comment
      t.string :email
      t.integer :user_id
      t.integer :value

      t.timestamps null: false
    end
  end
end
