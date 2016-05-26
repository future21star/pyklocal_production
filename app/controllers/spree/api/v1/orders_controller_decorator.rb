module Spree
	Api::V1::OrdersController.class_eval do 

		def index
			@orders_list = []
			@stores = Merchant::Store.all
			unless @stores.blank?
				@stores.each do |store|
					unless store.pickable_store_orders.blank?
						@orders_list << store.pickable_store_orders.map do |s_o|
							{number: s_o.number, store_name: store.name}
						end
					end
				end
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @orders_list
		end

	end
end