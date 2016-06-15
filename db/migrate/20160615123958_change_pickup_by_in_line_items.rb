class ChangePickupByInLineItems < ActiveRecord::Migration
  def up
  	remove_column :spree_line_items, :pickup_by
  	add_column :spree_line_items, :driver_id, :integer
  end
  def down
  	add_column :spree_line_items, :pickup_by, :string
  	remove_column :spree_line_items, :driver_id
  end
end
