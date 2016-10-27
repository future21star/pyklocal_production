class AddViewCounterToProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :view_counter, :integer
  end
end
