class ChangeTableCustomerReturnItem < ActiveRecord::Migration

  def change
		change_table :customer_return_items do |t|
		  t.remove :refunded, :status, :approve_qty
		  t.integer :store_id
		end
  end
end
