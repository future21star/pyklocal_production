class AddTransactionIdToCustomerReturnItem < ActiveRecord::Migration
  def change
    add_column :customer_return_items, :transaction_id, :string
  end
end
