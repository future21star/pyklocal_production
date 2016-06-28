class CreateDriversOrders < ActiveRecord::Migration
  def change
    create_table :drivers_orders do |t|
      t.integer :order_id
      t.integer :driver_id
      t.boolean :is_delivered, defalut: false
      t.string :line_item_ids

      t.timestamps null: false
    end
  end
end
