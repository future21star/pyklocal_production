module Spree
	class Seller < ActiveRecord::Base

		self.table_name = "spree_users"
		has_many :payment_histories, foreign_key: :user_id, class_name: "Spree::PaymentHistory"

		def full_name
	    (first_name || last_name) || (email)
	  end
		
	end
end