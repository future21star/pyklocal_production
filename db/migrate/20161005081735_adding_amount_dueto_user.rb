class AddingAmountDuetoUser < ActiveRecord::Migration
  def up
  	add_column :spree_users ,:amount_due ,:decimal
  end

  def down
  	remove_column :spree_users, :amount_due, :decimal
  end
end
