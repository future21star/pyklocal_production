class AddHiddenAttributeToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :hidden, :boolean
  end
end
