class AddInCartInLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :in_cart, :boolean, default: false
  end
end
