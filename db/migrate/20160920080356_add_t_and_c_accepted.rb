class AddTAndCAccepted < ActiveRecord::Migration
  def change
    add_column :spree_users, :t_and_c_accepted, :boolean, default: false
  end
end
