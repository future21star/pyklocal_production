class AddIsPickedupInLineItems < ActiveRecord::Migration
  def change
  	add_column :spree_line_items, :is_pickedup, :boolean, default: false
  	add_column :spree_line_items, :pickup_by,  :string
  end
end
