module Spree
	Api::V1::UsersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_filter :find_user, only: [:show, :profile, :get_cart, :get_orders, :my_pickup_list, :update_location, :update, :pickup, :my_cart, :add_to_cart, :remove_from_cart, :my_delivery_list, :mark_as_deliver]
		skip_before_filter :authenticate_user, only: [:profile, :my_pickup_list, :update_location, :pickup, :update, :my_cart, :add_to_cart, :remove_from_cart, :my_delivery_list, :mark_as_deliver]

		# Adding user_devices data regarding a driver
		def user_devices
			@api_token = Spree::ApiToken.where(token: params[:user_id]).first
			@user = @api_token.try(:user)
			if @user
				@user_device = @user.user_devices.where(device_token: params[:user_device][:device_token], device_type: params[:user_device][:device_type]).first_or_initialize
				if @user_device.new_record?
					@user_device.attributes = user_device_param.merge(user_id: @user.id)
					if @user_device.save
						@response = get_response
					else
						@response = error_response
						@response[:message] = @user_device.errors.full_messages.join(", ")
					end
				else
					@response = get_response
				end
			else
				@response = get_response
				@response[:message] = "User not found, invalid token."
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		def profile
			if @user
				render json:{
					status: "1",
					message: "User Details",
					details: to_stringify_user(@user , [])
				}
			else
				render json: {
					status: "0",
					message: "user does not exist"
				}
			end
		end

		# add_cart_cart a order if order is ready_to_pick
		# def add_to_cart
		# 	params[:order_object].each do |ord_obj|
		# 		order = Spree::Order.find_by_number(ord_obj["order_number"])
		# 		line_items = order.line_items.where(id: ord_obj["line_item_ids"])
		# 		if @user.driver_orders.where(line_item_ids: ord_obj["line_item_ids"].join(", ")).blank?
		# 			line_items.update_all(delivery_state: "in_cart")
		# 			@user.driver_orders.create(line_item_ids: ord_obj["line_item_ids"].join(", "), order_id: order.id)
		# 		end
		# 	end
		# 	@response = get_response
		# 	@response[:message] = "Successfully added into cart"
		# rescue Exception => e
		# 	api_exception_handler(e)
		# ensure
		# 	render json: @response
		# end

		# # See list of orders in a drivers cart
		# def my_cart
		# rescue Exception => e
		# 	api_exception_handler(e)
		# ensure
		# 	if @user.try(:drivers_cart).present?
		# 		render json: @user.drivers_cart.as_json
		# 	else
		# 		@response = error_response
		# 		@response[:message] = "No cart item available"
		# 		render json: @response
		# 	end
		# end

		# # Remove orders form driver's cart
		# def remove_from_cart
		# 	params[:cancel_orders].each do |cancel_order|
		# 		@order = Spree::Order.find_by_number(cancel_order["order_number"])
		# 		@line_items = @order.line_items.where(id: cancel_order["line_item_ids"])
		# 		@driver_orders = @user.driver_orders.where(order_id: @order.id, line_item_ids: cancel_order["line_item_ids"].join(", "))
		# 		if @driver_orders.present?
		# 			@driver_orders.delete_all
		# 			if Spree::DriverOrder.where(order_id: @order.id, line_item_ids: cancel_order["line_item_ids"]).blank?
		# 				@line_items.update_all(delivery_state: "ready_to_pick")
		# 			end
		# 		end
		# 	end
		# 	@response = get_response
		# 	@response[:message] = "Successfully removed from cart"
		# rescue Exception => e
		# 	api_exception_handler(e)
		# ensure
		# 	render json: @response
		# end

		#Pickup item(s) added in the cart
		def pickup
			begin
				p "================================================================"
				p params[:line_items_object]
				p params[:line_items_object].collect{|x| x[:order_number]}
				params[:line_items_object].collect{|x| x[:order_number]}.each do |order|
					p "^^^^^^^^^^^^^^^^^^"
					p order
					if Spree::Order.find_by_number(order).state == 'canceled'
						p "4444444444444444444444444444444"
						render json:{
							status: "0",
							message: "Item(s) you are trying to pick has been canceled. Please refresh."
						}
						return
					end
				end
				driver_id = eval(params[:option]) ? @user.id : nil
				state = eval(params[:option]) ? "confirmed_pickup" : "ready_to_pick"
				params[:line_items_object].each do |item_obj|
					order = Spree::Order.find_by_number(item_obj["order_number"])
					line_items = order.line_items.where(id: item_obj["line_item_ids"])
					if eval(params[:option])
						driver_order = Spree::DriverOrder.where(order_id: order.id, line_item_ids: item_obj["line_item_ids"].join(", "), driver_id: @user.id).first_or_initialize
						driver_order.save
					else
						@user.driver_orders.where(order_id: order.id, line_item_ids: item_obj["line_item_ids"].join(", ")).delete_all
					end
					line_items.update_all(driver_id: driver_id, delivery_state: state)
				end

				@response = get_response
				@response[:message] = eval(params[:option]) ? "Item(s) picked up by you" : "You have canceled this pickup"
				render json: @response
			rescue Exception => e
				render json:{
					status: "0",
					message: e.message.to_s
				}
			end
		end

		#See list of picked item(s)
		def my_pickup_list
		rescue Exception => e
			api_exception_handler(e)
		ensure
			unless @user.driver_orders_list.blank?
				render json: @user.driver_orders_list.as_json()
			else
				@response = error_response
				@response[:message] = "No item(s) in your list"
				p @response
				render json: @response.as_json()
			end
		end

		#Set item as delivered
		def mark_as_deliver
			@order = Spree::Order.find_by_number(params[:order_number])
			if @order.state != 'canceled'
				@line_items = @order.line_items.where(id: params[:line_item_ids], delivery_state: "out_for_delivery")
				if @line_items.present?
					@line_items.update_all(delivery_state: "delivered")
					@user.driver_orders.where(order_id: @order.try(:id), line_item_ids: params[:line_item_ids].join(", ")).update_all(is_delivered: true)
					@response = get_response
					@response[:message] = "Successfully delivered"
				else
					@response = error_response
					@response[:message] = "Line item or order not present"
				end
			else
				@response = error_response
				@response[:message] = "order is already canceled"
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		#See the list of item(s) you delivered
		def my_delivery_list
		rescue Exception => e
			api_exception_handler(e)
		ensure
			if @user.try(:delivered_orders).present?
				render json: @user.delivered_orders.as_json
			else
				@response = error_response
				@response[:message] = "No order(s) available"
				render json: @response
			end
		end

		#Update Users information
		def update
			if @user.update_attributes(user_params)
				@response = get_response
			else
				@response = error_response
				@response[:message] = @user.errors.full_messages.join(", ")
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		def get_cart
			variant_arr = []
			@order = @user.orders.where("state != ? AND state != ? AND state != ?","complete","canceled","returned").last
			unless @order.blank?
				render json: {
					status: "1",
					message: "Cart",
					cart_count: @user.cart_count.to_s,
					order_number: @order.number.to_s,
					order_token: @order.guest_token.to_s,
					order_state: @order.state.to_s,
					details: to_stringify_variant_json(@order, @user, [])
				}
			else
				render json: {
					status: "0",
					message: "Cart is empty",
				}
			end
		end

		def get_orders 
			@orders = @user.orders.where("state != ? AND state != ? AND state != ? AND state != ?","cart", "address", "delivery",'payment').order('created_at desc')
			# @orders = @user.orders.where(state: 'complete')
			unless @orders.blank?
				render json:{
					status: "1",
					message: "Order Detail",
					detail: to_stringify_order_json(@orders, [])
				}
			else
				render json:{
					status: "0",
					message: "No Order Found"
				}
			end
		end

		#Update drivers location
		def update_location
			if @user.api_tokens.last.update_attributes(latitude: params[:latitude], longitude: params[:longitude])
				@response = get_response
			else
				@response = error_response
				@response[:message] = @user.errors.full_messages.join(", ")
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		def show
			render json: @user.as_json({
				only: [:email, :first_name, :last_name]
			})
		end

		private

		def to_stringify_order_json obj , values = []
			obj.each do |order|
				order_hash = Hash.new
				order_hash["order_number".to_sym] = order.number.to_s
				order_hash["order_date".to_sym] = order.completed_at.to_s
				order_hash["state".to_sym] = order.state.to_s
				if order.state != "canceled" && order.is_any_item_shipped? == false && (order.completed_at.to_date + 14.days) >= Date.today
					order_hash["shipped".to_sym] = "0"
				elsif order.state != "canceled" && order.is_any_item_shipped? == true && (order.completed_at.to_date + 14.days) >= Date.today
					order_hash["shipped".to_sym] = "1"
				else
					order_hash["shipped".to_sym] = "2"
				end
					
				unless order.payments.valid.last.try(:source).nil?
					if order.payments.valid.last.source.paypal_email.nil?
						order_hash["payment".to_sym]  = "Ending in " + order.payments.valid.last.source.try(:braintree_last_digits) + '(' + ActionController::Base.helpers.number_to_currency(order.payments.valid.last.amount.to_f) + ')' 
					else
						order_hash["payment".to_sym] = order.payments.valid.last.source.try(:paypal_email).to_s + '(' + ActionController::Base.helpers.number_to_currency(order.payments.valid.last.amount.to_f) + ')' 
					end
				else
					order_hash["payment".to_sym] = "Check " + '(' + ActionController::Base.helpers.number_to_currency(order.payments.valid.last.amount.to_f) + ')' 
				end
				# if order.payments.valid.source.nil?
				# 	order_hash["payment".to_sym] = "hello"
				# else
				# 	order_hash["payment".to_sym] = "Bye"
				# end
				unless order.self_pickup
					order_hash["shipment".to_sym] = "Delivery within 6 - 8 woking hours with cost " + ActionController::Base.helpers.number_to_currency(order.shipments.last.selected_shipping_rate.cost.to_f)
				else
					order_hash["shipment".to_sym] = ""
				end

				if Spree::Address.exists?(order.bill_address_id)
					order_hash["bill_address".to_sym] = order.bill_address.get_address
				else
					order_hash["bill_address".to_sym] = {}
				end


				if Spree::Address.exists?(order.ship_address_id)
					order_hash["shipping_address".to_sym] = order.ship_address.get_address
				else
					order_hash["shipping_address".to_sym] = {}
				end

				if order.try(:line_items)
						line_item_arr = []
						order.line_items.each do|line_item|
							line_items_hash = Hash.new
							line_items_hash["id".to_sym] = line_item.id.to_s
							line_items_hash["quantity".to_sym] = line_item.quantity.to_s
							line_items_hash["price".to_sym] = line_item.price.to_s
							line_items_hash["delivery_type".to_sym] = line_item.delivery_type.to_s
							if line_item.delivery_type == 'pick_up' || line_item.delivery_type == 'pickup'
							 line_items_hash["delivery_state".to_sym] = 'NA'
							elsif line_item.delivery_state == 'packaging'
								line_items_hash["delivery_state".to_sym] = 'In Process'
							elsif line_item.delivery_state == 'ready_to_pick'
								line_items_hash["delivery_state".to_sym] = 'Ready For Pick Up'
							elsif line_item.delivery_state == 'confirmed_pickup'
								line_items_hash["delivery_state".to_sym]  = 'Waiting For Driver'
							elsif line_item.delivery_state == 'out_for_delivery'
								line_items_hash["delivery_state".to_sym] = 'Out For Delivery'
							elsif line_item.delivery_state == 'delivered'
								line_items_hash["delivery_state".to_sym] = 'Delivered' 
							end
							line_items_hash["variant_id".to_sym] = line_item.variant_id.to_s
							line_items_hash["product_name".to_sym] = line_item.product.name.to_s
							line_items_hash["product_id".to_sym] = line_item.product.id.to_s
							line_items_hash["cost_currency".to_sym] = line_item.variant.cost_currency.to_s
							line_items_hash["sku".to_sym] = line_item.variant.sku.to_s
							line_items_hash["option_name".to_sym] = line_item.variant.option_name.to_s
							line_items_hash["price".to_sym] = line_item.price.to_f.round(2).to_s
							if line_item.variant.product.store.present?
								line_items_hash["store_id".to_sym] = line_item.variant.product.store.id.to_s
								line_items_hash["store_name".to_sym] = line_item.variant.product.store.name.to_s
								line_items_hash["store_address".to_sym] = line_item.variant.product.store.address.to_s
							else
								line_items_hash["store_id".to_sym] = ""
								line_items_hash["store_name".to_sym] = ""
								line_items_hash["store_address".to_sym] = ""
							end

							if line_item.variant.images
								line_items_hash["images".to_sym] = line_item.variant.product_images
							else
								line_items_hash["images".to_sym] = []
							end

							line_item_arr.push(line_items_hash)
						end
						order_hash["line_items"] = line_item_arr
				else
					order_hash["line_items"] = []
				end
				 order_hash["adjustments".to_sym] = get_order_adjustments(order)
				 values.push(order_hash)
			end
			return values
		end

			def user
				@user = Spree::ApiToken.where(token: params[:user_id]).first.try(:user)
				# render json: {code: 0, message: "User not found, invalid login token"}
			end
	
			def user_device_param
				params.require(:user_device).permit(:device_token, :device_type, :user_id, :notification)
			end


			def find_user
				id = params[:id] || params[:user_id]
				@user = Spree::ApiToken.where(token: id).first.try(:user)
				render json: {status: 0, message: "User not found"} unless @user.present?
			end
	end
end