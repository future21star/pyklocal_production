class AddDeletedAtToPyklocalStoreUsers < ActiveRecord::Migration
  def change
    add_column :pyklocal_stores_users, :deleted_at, :datetime, class: "Merchant::StoreUser"
  end
end
