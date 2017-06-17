module Spree
	class PaymentHistoriesController < Spree::StoreController
    # before_filter :authenticate_spree_user!
		def index
			@payment_histories = spree_current_user.payment_histories
		end 
	end
end