class CreateCustomerReturnItems < ActiveRecord::Migration
  def change
    create_table :customer_return_items do |t|
    	t.integer :order_id
    	t.integer :line_item_id
    	t.integer :return_quantity
    	t.string :refunded
    	t.string :status

      t.timestamps 
    end
  end
end
