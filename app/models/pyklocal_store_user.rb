class PyklocalStoreUser < ActiveRecord::Base
	self.table_name = "pyklocal_stores_users"
	belongs_to :pyklocal_store, foreign_key: :store_id
	belongs_to :spree_user, foreign_key: :spree_user_id, class_name: 'Spree::User'
	
	belongs_to :spree_buy_privilege
  belongs_to :spree_sell_privilege
end
