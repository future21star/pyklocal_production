class CreateUserStoreRating < ActiveRecord::Migration
  def change
    create_table :users_stores_ratings do |t|
      t.integer :user_id
      t.integer :store_id
      t.float :rating
      t.text :comment

      t.timestamps
    end
  end
end
