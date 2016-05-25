class AddFieldsInLineItem < ActiveRecord::Migration
  def change
  	add_column :spree_line_items, :ready_to_pick, :boolean, default: false
  end
end
