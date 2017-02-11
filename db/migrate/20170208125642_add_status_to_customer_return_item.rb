class AddStatusToCustomerReturnItem < ActiveRecord::Migration
  def change
    add_column :customer_return_items, :status, :string
  end
end
