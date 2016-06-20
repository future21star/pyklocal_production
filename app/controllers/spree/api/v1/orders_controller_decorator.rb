module Spree
	Api::V1::OrdersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_action :load_order, only: [:show, :pickup]
		before_action :find_store, only: [:show]
		skip_before_filter :authenticate_user, only: [:pickup, :apply_coupon_code]

		def index
			@orders_list = []
			@stores = Merchant::Store.all
			unless @stores.blank?
				@stores.each do |store|
					unless store.pickable_store_orders.blank?
						store.pickable_store_orders.map do |s_o|
							@orders_list.push({number: s_o.number, store_name: store.name})
						end
					end
				end
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @orders_list.as_json()
		end

		def show
			@store_line_items = []
			@pick_up_and_delivery = {}
			@order.line_items.each do |line_item|
				if @store.spree_products.include?(line_item.product)
					@store_line_items.push(line_item)
					@pick_up_and_delivery = {store_address: line_item.pickup_address, store_zipcode: line_item.store_zipcode, buyer_name: line_item.buyer_name, buyer_address: line_item.delivery_address, buyer_zipcode: line_item.buyer_zipcode, lat_long: line_item.store_location}
				end
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: {
				product_details: @store_line_items.as_json({
					only: [:id, :price, :quantity], 
					methods: [:product_name]
				}),
				pick_up_and_delivery: @pick_up_and_delivery.as_json()
			}
		end

		def pickup
			@user = Spree::ApiToken.where(token: params[:user_id]).first.try(:user)
			driver_id = eval(params[:option]) ? nil : @user.try(:id)
			updating_value = eval(params[:option]) ? @user.try(:id) : nil
			@line_items = @order.line_items.where(id: params[:line_item_ids], is_pickedup: !eval(params[:option]), ready_to_pick: true, delivery_type: "home_delivery", driver_id: driver_id)

			if @line_items.present?
				@line_items.find_each { |line_item| line_item.update_attributes(is_pickedup: eval(params[:option]), driver_id: updating_value) }
				@response = get_response
				@response[:message] = eval(params[:option]) ? "Item(s) picked up by you" : "You have canceled this pickup"
			else
				@response = error_response
				@response[:message] = "Item not found either cancel by seller or picked up by another driver."
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		private

			def load_order
				id = params[:id] || params[:order_id]
				@order = Spree::Order.find_by_number(id)
			end

			def find_store
				@store = Merchant::Store.find_by_name(params[:store_name])
				render json: {code: 0, message: "Store not found, invalid store name"} unless @store.present?
			end

	end
end