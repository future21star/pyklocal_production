class ModifyLineItems < ActiveRecord::Migration
  def up
    remove_column :spree_line_items, :ready_to_pick
    remove_column :spree_line_items, :is_pickedup
    remove_column :spree_line_items, :in_cart
    add_column :spree_line_items, :delivery_state, :string, default: "packaging"
  end

  def down
    add_column :spree_line_items, :ready_to_pick, :boolean, default: false
    add_column :spree_line_items, :is_pickedup, :boolean, default: false
    add_column :spree_line_items, :in_cart, :boolean, default: false
    remove_column :spree_line_items, :delivery_state
  end

end
