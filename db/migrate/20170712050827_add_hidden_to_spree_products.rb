class AddHiddenToSpreeProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :hidden, :boolean, :default => false
  end
end
