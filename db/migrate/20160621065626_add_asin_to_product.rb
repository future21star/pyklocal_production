class AddAsinToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :asin, :string
  end
end
