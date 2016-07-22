class DropUserStoreRating < ActiveRecord::Migration
  def up
    drop_table :users_stores_ratings
    create_table :comments do |t|
      t.integer :user_id
      t.integer :commentable_id
      t.string :commentable_type
      t.text :comment

      t.timestamps
    end
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :rateable_id
      t.string :rateable_type
      t.float :rating, default: 0

      t.timestamps
    end
  end
  def down
    create_table :users_stores_ratings do |t|
      t.integer :user_id
      t.integer :store_id
      t.float :rating
      t.text :comment

      t.timestamps
    end
    drop_table :comments
    drop_table :ratings
  end
end
