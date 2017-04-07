module Spree

	class Api::V1::RegistrationsController < Spree::Api::BaseController

		skip_before_filter :authenticate_user
    include Spree::Api::SessionsHelper

		def create
			if params[:is_guest].eql?"true" 
				if params[:user][:device_id]
					@api_token = ApiToken.where(user_device_id: params[:user][:device_id]).last
					if @api_token
						@user = @api_token.user
						if @user.update_attributes(email: params[:user][:email], password: params[:user][:password], is_guest: false)
							@response[:message] = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
							@response = get_response(@user)
						else
							@response = error_response
			        @response[:message] = @user.errors.full_messages.join(", ")
						end
					else
						@response = error_response
			      @response[:message] = "Invalid Device Id"
					end
				else
					@response = error_response
					@response[:message] = "Device id can not be blank"
				end
			else
				@user = Spree.user_class.new(user_params)
				if @user.save
	      	@response = get_response(@user)
	      	@response[:message] = "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
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