module Spree
	Api::V1::OrdersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_action :load_order, only: [:show]
		before_action :find_store, only: [:show]
		before_action :find_driver, only: [:index, :show]
		skip_before_filter :authenticate_user, only: [:apply_coupon_code]

		def index
			@orders_list = []
			params[:lat] = @user.api_tokens.last.try(:latitude)
			params[:lng] = @user.api_tokens.last.try(:longitude)
			@search = Sunspot.search(Merchant::Store) do
				order_by_geodist(:loctn, params[:lat], params[:lng])
			end
			@stores = @search.results
			unless @stores.blank?
				@stores.each do |store|
					unless store.pickable_store_orders.blank?
						store.pickable_store_orders.each do |s_o|
							line_items = s_o.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: store.id})
							line_item_ids = line_items.collect(&:id)
							@orders_list.push({order_number: s_o.number, store_name: store.name, line_item_ids: line_item_ids, state: line_items.collect(&:delivery_state).uniq.join, location: {lat: store.try(:latitude), long: store.try(:longitude)}})
						end						
					end
				end
			end
			render json: @orders_list.as_json()
		# rescue Exception => e
		# 	api_exception_handler(e)
		# ensure
		# 	render json: @orders_list.as_json()
		end

		def show
			# @user = Spree::ApiToken.where(token: params[:token]).try(:first).try(:user)
			line_items = @order.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: @store.id})
			pick_up_and_delivery = {
																store_address: @store.address, 
																store_zipcode: @store.zipcode, 
																buyer_name: @order.buyer_name, 
																buyer_address: @order.delivery_address, 
																buyer_zipcode: @order.buyer_zipcode, 
																lat_long: @store.location
															}
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: {
				product_details: line_items.as_json({
					only: [:id, :price, :quantity], 
					methods: [:product_name]
				}),
				state: line_items.collect(&:delivery_state).uniq.join,
				pick_up_and_delivery: pick_up_and_delivery
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

			def find_driver
				@user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
				render json: {code: 0, message: "Driver not found"} unless @user.present?
			end

	end
end