module Spree
	Api::V1::UsersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_filter :find_user, only: [:my_pickup_list, :update_location, :update, :pickup]
		skip_before_filter :authenticate_user, only: [:my_pickup_list, :update_location, :pickup]

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


		def pickup
			driver_id = eval(params[:option]) ? nil : @user.try(:id)
			updating_value = eval(params[:option]) ? @user.try(:id) : nil
			params[:order_ids].each do |orders|
				@orders = Spree::Order.where(number:orders).first
				@line_items = @orders.line_items.where(id: params[:line_item_ids], is_pickedup: !eval(params[:option]), ready_to_pick: true, delivery_type: "home_delivery", driver_id: driver_id)
				if @line_items.present?
					@line_items.find_each { |line_item| line_item.update_attributes(is_pickedup: eval(params[:option]), driver_id: updating_value) }
					@response = get_response
					@response[:message] = eval(params[:option]) ? "Item(s) picked up by you" : "You have canceled this pickup"
				else
					@response = error_response
					@response[:message] = "Item not found either cancel by seller or picked up by another driver."
				end
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		def my_pickup_list
			@orders = @user.driver_orders_list
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @orders.as_json()
		end

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

		private

			def user
        @user = Spree::ApiToken.where(token: params[:user_id]).first.try(:user)
      end

			def user_device_param
				params.require(:user_device).permit(:device_token, :device_type, :user_id, :notification)
			end

			def find_user
				id = params[:id] || params[:user_id]
				@user = Spree::ApiToken.where(token: id).first.try(:user)
			end
	end
end