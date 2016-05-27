module Spree
	class PaymentHistory < ActiveRecord::Base

		self.table_name = "payment_histories"
		belongs_to :user
		
	end
end