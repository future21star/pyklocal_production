class AddActiveToProducts < ActiveRecord::Migration

  def change
  	add_column :spree_products, :buyable, :boolean, default: true
  end
end
