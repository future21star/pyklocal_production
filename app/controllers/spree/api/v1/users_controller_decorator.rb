module Spree
	Api::V1::UsersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_filter :find_user, only: [:show, :profile, :my_pickup_list, :update_location, :update, :pickup, :my_cart, :add_to_cart, :remove_from_cart, :my_delivery_list, :mark_as_deliver]
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
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @user.as_json({
				only: [:first_name, :last_name, :email]
			})
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
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
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
				render json: @response.as_json()
			end
		end

		#Set item as delivered
		def mark_as_deliver
			@order = Spree::Order.find_by_number(params[:order_number])
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
				render json: {code: 0, message: "User not found"} unless @user.present?
			end
	end
end