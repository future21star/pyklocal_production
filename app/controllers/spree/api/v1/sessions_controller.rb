module Spree
	class Api::V1::SessionsController < Api::BaseController

		skip_before_filter :authenticate_user

		include Spree::Api::SessionsHelper

		def create
			if required_params_present? params, 'email', 'password'
				user = Spree::User.find_by_email(params[:email])
				unless user.blank?
					if user.valid_password?(params[:password])
						@response = get_response(user)
						@response[:message] = "Login successfull"
					else
						@response = error_response
						@response[:message] = "Invalid password"
					end
				else
					@response = error_response
					@response[:message] = "Invalid email"
				end
			end
		rescue Exception => e
			api_exception_handler(e)
		ensure 
			render json: @response
		end

	end
end