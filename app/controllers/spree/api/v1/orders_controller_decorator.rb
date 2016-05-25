module Spree
	Api::V1::OrdersController.class_eval do 

		def index
			@orders = []
			@stores = Merchant::Store.all
			unless @stores.blank?
				@stores.each do |store|
					@orders << store.store_orders
				end
			end
			render json: @orders.flatten.to_josn({
				only: [:number]
			})
		end

	end
end