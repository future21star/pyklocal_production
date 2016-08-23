class AddIsGuestInUsers < ActiveRecord::Migration
  def change
  	add_column :spree_users, :is_guest, :boolean, default: false
  end
end
