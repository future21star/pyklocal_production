module Spree
	Api::V1::OrdersController.class_eval do 

		def index
			@orders_list = {}
			@stores = Merchant::Store.all
			unless @stores.blank?
				@stores.each do |store|
					unless store.store_orders.blank?
						@orders_list = store.store_orders.map do |s_o|
							{number: s_o.number, store_name: store.name}
						end
					end
				end
			end
			render json: @orders_list.to_json
		end

	end
end