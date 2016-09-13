class AddDefaultNameToUser < ActiveRecord::Migration
  def up
  	  change_column :spree_users, :first_name, :string, :default => ""
  	  change_column :spree_users, :last_name,  :string, :default => ""

  end

  def down
  	  change_column :spree_users, :first_name, :string
  	  change_column :spree_users, :last_name,  :string

  end
end
