module Spree
	class PaymentPreference < ActiveRecord::Base

		self.table_name = "payment_preferences"
		belongs_to :user
		
	end
end