class AddStoreIdToSpreeReturnAuthorizationReasons < ActiveRecord::Migration
  def change
    add_column :spree_return_authorization_reasons, :store_id, :string
  end
end
