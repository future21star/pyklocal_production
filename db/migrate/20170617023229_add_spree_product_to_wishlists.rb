class AddSpreeProductToWishlists < ActiveRecord::Migration
  def change
    add_reference :wishlists, :spree_product, index: true, foreign_key: true
  end
end
