module Spree
	Api::V1::UsersController.class_eval do 

		include Spree::Api::ApiHelpers

		before_filter :find_user, only: [:my_pickup_list]
		skip_before_filter :authenticate_user, only: :my_pickup_list

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

		def my_pickup_list
			@orders = @user.driver_orders_list
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @orders.as_json()
		end

		private

			def user_device_param
				params.require(:user_device).permit(:device_token, :device_type, :user_id, :notification)
			end

			def find_user
				@user = Spree::ApiToken.where(token: params[:user_id]).first.try(:user)
			end
	end
end