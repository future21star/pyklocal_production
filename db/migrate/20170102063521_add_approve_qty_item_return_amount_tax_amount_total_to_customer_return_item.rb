class AddApproveQtyItemReturnAmountTaxAmountTotalToCustomerReturnItem < ActiveRecord::Migration
  def change
  	add_column :customer_return_items, :approve_qty, :integer
  	add_column :customer_return_items, :item_return_amount, :float
  	add_column :customer_return_items, :tax_amount, :float
  	add_column :customer_return_items, :total, :float
	end
end
