module Spree
	class Api::V1::SessionsController < Api::BaseController

		skip_before_filter :authenticate_user

		include Spree::Api::SessionsHelper

		def create
			if params[:is_guest]
				@api_token = ApiToken.where(user_device_id: params[:device_token],expire: nil).last
				if !@api_token
					email = SecureRandom.hex(4)+"@pyklocal.com"
					password = SecureRandom.hex(4)
					@user = Spree::User.new(email: email, password: password, password_confirmation: password, is_guest: true)
					if @user.save
						@response = get_response(@user)
						@response[:message] = "Login successfull"
					else
						@response = error_response
						@response[:message] = @user.errors.full_messages.join(", ")
					end
				else
					@response =get_response(@api_token.user)
					@response[:message] = "User Already logged in"
				end
			elsif required_params_present? params, 'email', 'password'
				user = Spree::User.find_by_email(params[:email])
				unless user.blank?
					if user.valid_password?(params[:password])
						if user.has_spree_role?("driver")
							@response = get_response(user)
							@response[:message] = "Login successfull"
						else
							@response = error_response
							@response[:message] = "Your account has not actived by admin"
						end
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


		def destroy
			@token=ApiToken.where(token: params[:id], expire: nil).last
			if @token
				if @token.update_attributes(expire: Time.zone.now)
					render json: {status: "1", message: "Log Out successfully"}
				else
					render json: {status: "0", message: "Something went wrong"}
				end
			else
				render json: {status: "0", message: "Already Logged out"}
			end

		end

	end
end