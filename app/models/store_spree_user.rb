class StoreSpreeUser < ActiveRecord::Base
	belongs_to :store
	belongs_to :spree_user, foreign_key: :spree_user_id, class_name: 'Spree::User'
	
	belongs_to :spree_buy_privilege
    belongs_to :spree_sell_privilege
end
