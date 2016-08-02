class AddReturnAuthorizationReasonIdToSpreeCustomerReturns < ActiveRecord::Migration
  def change
    add_column :spree_customer_returns, :return_authorization_reason_id, :string
  end
end
