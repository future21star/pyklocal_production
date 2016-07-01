class AddUserIdToAddresses < ActiveRecord::Migration
  def change
    add_column :spree_addresses, :user_id, :string
  end
end
