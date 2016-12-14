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
			@orders = @user.orders.where("state != ? AND state != ? AND state != ?","cart", "address", "shipment")
			unless @orders.blank?
				render json:{
					status: "1",
					message: "Order Detail",
					detail: to_stringify_order(@orders, [])
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

		def to_stringify_order obj , values = []
			obj.each do |c_obj|
				order_hash = Hash.new
				skip_order_attributes = ["last_ip_address","created_by_id","approver_id","approved_at","confirmation_delivered","canceled_at","store_id"]
        checkout_step_arr = ["address" ,"delivery", "payment", "complete"]
          # c_obj.attributes.each do |k,v|
          #     unless skip_order_attributes.include? k
          #       if k.eql?"bill_address_id"  
          #         if v
          #           order_hash["bill_address".to_sym] = c_obj.bill_address.get_address
          #         else
          #           order_hash["bill_address".to_sym] = []
          #          end
          #       end

          #       if k.eql?"ship_address_id"  
          #         if v
          #           order_hash["ship_address".to_sym] = c_obj.ship_address.get_address
          #         else
          #           order_hash["ship_address".to_sym] = []
          #         end
          #       end

          #       order_hash[k.to_sym] = v.to_s
          #     end 
          # end
          order_hash[""]
          if c_obj.try(:line_items)
            line_item_arr = []
            c_obj.line_items.each do|line_item|
              line_items_hash = Hash.new
              line_items_hash["id".to_sym] = line_item.id.to_s
              line_items_hash["quantity".to_sym] = line_item.quantity.to_s
              line_items_hash["price".to_sym] = line_item.price.to_s
              line_items_hash["variant_id".to_sym] = line_item.variant_id.to_s
              variant_hash = Hash.new
              line_item.variant.attributes.each do|k,v|
                  variant_hash[k.to_sym] = v.to_s
              end
              
              variant_hash["stock_status"] = line_item.variant.stock_status.to_s
              variant_hash["option_name"] = line_item.variant.option_name

              if line_item.variant.images
                variant_hash["images".to_sym] = line_item.variant.product_images
              else
                variant_hash["images".to_sym] = []
              end

              line_items_hash["variants"] = variant_hash
              line_item_arr.push(line_items_hash)
            end
            order_hash["line_items"] = line_item_arr
          else
            order_hash["line_items"] = []
          end
          
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

			def to_stringify_variant_json obj, user ,values = []
				obj.line_items.each do |line_item|
					variants_hash = Hash.new
					variants_hash["line_item_id".to_sym] = line_item.id.to_s
					variants_hash["quantity".to_sym] = line_item.quantity.to_s
					variants_hash["delivery_type".to_sym] = line_item.delivery_type.to_s
					variants_hash["product_id".to_sym] = line_item.variant.product.id.to_s
					variants_hash["product_name".to_sym] = line_item.variant.product.name.to_s

					variant = line_item.variant
          variants_hash["variant_id".to_sym] = variant.id.to_s
          variants_hash["price".to_sym] = variant.cost_price.to_f.to_s
          variants_hash["special_price".to_sym] = variant.price.to_f.to_s
          variants_hash["discount".to_sym] = variant.discount.to_s
          variants_hash["total_on_hand"] = variant.total_on_hand.to_s
          variants_hash["stock_status"] = variant.stock_status.to_s 
          variants_hash["minimum_quantity".to_sym] = "1"

					variants_hash["option_name"] = variant.option_name

          if variant.images.present?
          	p "888888888888888888888888888888888888888888888888888"
            variants_hash["product_images".to_sym] = variant.product_images
          elsif variant.product.images.present?
          	p "********************************************************************"
          	variants_hash["product_images".to_sym] = variant.product.product_images
          else
          	variants_hash["product_images".to_sym] = []
				  end
				  values.push(variants_hash)
				end
				return values
			end

			def find_user
				id = params[:id] || params[:user_id]
				@user = Spree::ApiToken.where(token: id).first.try(:user)
				render json: {status: 0, message: "User not found"} unless @user.present?
			end
	end
end