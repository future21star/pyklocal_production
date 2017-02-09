module Spree
	Refund.class_eval do

		belongs_to :order

		clear_validators!
		def amount_is_less_than_or_equal_to_allowed_amount
	      
	  end

		
	end
end