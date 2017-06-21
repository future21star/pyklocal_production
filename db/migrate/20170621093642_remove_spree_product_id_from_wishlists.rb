class RemoveSpreeProductIdFromWishlists < ActiveRecord::Migration
  def change
		remove_column :wishlists, :spree_product_id  	
  end
end
