class AddDefaultValueForIsDelivered < ActiveRecord::Migration
  def up
    change_column :drivers_orders, :is_delivered, :boolean, default: false
  end
  def down
    change_column :drivers_orders, :is_delivered, :boolean
  end
end
