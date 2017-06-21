class AddProductIdToWishlists < ActiveRecord::Migration
  def change
    add_column :wishlists, :product_id, :string
  end
end
