class AddMobileNumberFromUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :mobile_number, :string
  end
end
