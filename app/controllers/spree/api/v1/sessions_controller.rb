module Spree
	class Api::V1::SessionsController < Api::BaseController

		skip_before_filter :authenticate_user

		include Spree::Api::SessionsHelper

		def create
			if params[:is_guest].eql?"true" 
				if params[:device_id]
					@api_token = ApiToken.where(user_device_id: params[:device_id], expire: nil).last
					if !@api_token
						email = SecureRandom.hex(4)+"@pyklocal.com"
						password = SecureRandom.hex(4)
						@user = Spree::User.new(email: email, password: password, password_confirmation: password, is_guest: true, t_and_c_accepted: true)
						if @user.save
							@response = get_response(@user)
							@response[:message] = "Login successfull"
							@api_token1 = @user.api_tokens.last
							@api_token1.update_attributes(user_device_id: params[:device_id])
						else
							@response = error_response
							@response[:message] = @user.errors.full_messages.join(", ")
						end
					else
						@response =get_response(@api_token.user)
						@response[:message] = "User Already logged in"
					end
				else
					@response = error_response
					@response[:message] = "Device id can not be blank"
				end
			elsif required_params_present? params, 'email', 'password'
				# TODO:  Add condition for driver approcval
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
			p "exe"
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
				render json: {status: "0", message: "Already Logged out/ Invalid token"}
			end

		end

	end
end