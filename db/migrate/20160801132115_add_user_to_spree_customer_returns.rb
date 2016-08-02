class AddUserToSpreeCustomerReturns < ActiveRecord::Migration
  def change
    add_column :spree_customer_returns, :user_id, :string
  end
end
