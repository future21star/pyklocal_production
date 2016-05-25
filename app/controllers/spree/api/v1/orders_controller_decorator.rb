module Spree
	Api::V1::OrdersController.class_eval do 

		def index
			render json: Spree::LineItem.where(ready_to_pick: true)
		end

	end
end