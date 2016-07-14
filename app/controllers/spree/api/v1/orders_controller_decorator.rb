module Spree
	Api::V1::OrdersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_action :load_order, only: [:show]
		before_action :find_store, only: [:show]
		skip_before_filter :authenticate_user, only: [:apply_coupon_code]

		def index
			@orders_list = []
			@user = Spree::ApiToken.find_by_token(params[:token]).try(:user)
			@stores = Merchant::Store.all
			unless @stores.blank?
				@stores.each do |store|
					unless store.pickable_store_orders.blank?
						store.pickable_store_orders.each do |s_o|
							line_items = s_o.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: store.id})
							line_item_ids = line_items.collect(&:id)
							in_cart = @user.driver_orders.where(order_id: s_o.id, line_item_ids: line_item_ids.join(", ")).present?
							@orders_list.push({order_number: s_o.number, store_name: store.name, in_cart: in_cart, line_item_ids: line_item_ids, state: line_items.collect(&:delivery_state).uniq.join, location: {lat: store.try(:latitude), long: store.try(:longitude)}})
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
			line_items = @order.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: @store.id})
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: {
				product_details: line_items.as_json({
					only: [:id, :price, :quantity], 
					methods: [:product_name]
				}),
				pick_up_and_delivery: {store_address: @store.address, store_zipcode: @store.zipcode, buyer_name: @order.buyer_name, buyer_address: @order.delivery_address, buyer_zipcode: @order.buyer_zipcode, lat_long: @store.location}.as_json(),
				state: line_items.collect(&:delivery_state).uniq.join
			}
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