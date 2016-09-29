module Spree

	class Api::V1::RegistrationsController < Spree::Api::BaseController

		skip_before_filter :authenticate_user
    include Spree::Api::SessionsHelper

		def create
			@api_token = ApiToken.where(user_device_id: params[:user][:device_id]).last
			if @api_token
				@user = @api_token.user
				if @user.update_attributes(email: params[:user][:email], password: params[:user][:password], is_guest: false)
					@response = get_response(@user)
				else
					@response = error_response
	        @response[:message] = @user.errors.full_messages.join(", ")
				end
			else
				@user = Spree.user_class.new(user_params)
				if @user.save
	      	@response = get_response(@user)
	      else
	      	@response = error_response
	        @response[:message] = @user.errors.full_messages.join(", ")
	      end
	    end
    rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: @response
		end

		private

			def user_params
        params.require(:user).permit(:mobile_number, :role_name, permitted_user_attributes |
                                       [bill_address_attributes: permitted_address_attributes,
                                        ship_address_attributes: permitted_address_attributes])
      end

	end
end