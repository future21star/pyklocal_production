class RemoveBrandFromProducts < ActiveRecord::Migration
  def up
  	remove_column :spree_products, :brand
  end
  def down
    add_column :spree_products, :brand, :string
  end
end
