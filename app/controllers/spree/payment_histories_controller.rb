module Spree
	class PaymentHistoriesController < Spree::StoreController

	

		def index
			@payment_histories = spree_current_user.payment_histories
		end 
	end
end