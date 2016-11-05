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
							@api_token_guest = @user.api_tokens.last
							@api_token_guest.update_attributes(user_device_id: params[:device_id])
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
			elsif params[:provider]
				authentication = Authentication.where(:provider => params['provider'], :uid => params['uid']).first 
				unless authentication.blank?
					@response = get_response(authentication.user)
					@response[:message] = "Social Login successfull"
				else
					if required_params_present? params, 'email'
						@already_user = Spree::User.find_by_email(params[:email]) 
						if @already_user.blank?
							password = SecureRandom.hex(4)
							@user = Spree::User.new(email: params[:email],first_name: params[:first_name], last_name: params[:last_name], password: password, password_confirmation: password, t_and_c_accepted: true)
							if @user.save
								@auth = Authentication.new(provider: params[:provider], uid: params[:uid] ,user_id: @user.id)
								if @auth.save
									@response = get_response(@user)
									@response[:message] = "Social Sign up successfull"
								else
									@response = error_response
									@response[:message] = @auth.errors.full_messages.join(", ")
								end
							else
								@response = error_response
								@response[:message] = @user.errors.full_messages.join(", ")
							end
						else
							@response = get_response(@already_user)
							@response[:message] = "User Already Sign up With this email"
						end
					else
						@respone = error_response
						@response[:message] = "email can not be blank"
					end 
				end
			elsif required_params_present? params, 'email', 'password'
				# TODO:  Add condition for driver approval
				user = Spree::User.find_by_email(params[:email])
				unless user.blank?
					if user.valid_password?(params[:password])
						if params[:token]
							@is_guest_user = ApiToken.where(token: params[:token]).last.try(:user)
							if @is_guest_user.is_guest == true 
								unless @is_guest_user.orders.where.not(state: "complete").blank?
									unless user.orders.where.not(state: "complete").blank?
										@is_guest_user.orders.where.not(state: "complete").last.line_items.each do |line_item|
									 	 user.orders.last.contents.add(line_item.variant, line_item.quantity, {}, line_item.delivery_type)
									 	end
									else
									 	@is_guest_user.orders.last.update_attributes(user_id: user.id)
									end
									@response = get_response(user)
								  @response[:message] = "Login successfull"
								else
								  @response = get_response(user)
								  @response[:message] = "Login successfull"
								end
							else
								@respone = error_response
								@response[:message] = "User was not logged in as a guest user"
							end
						elsif params[:is_driver] && params[:is_driver] == "true"
							if user.has_spree_role?('driver')
								@response = get_response(user)
								@response[:message] = "Driver Login successfull"
							else
								@response = error_response
								@response[:message] = "User is not a driver"
							end
						else
							@response = get_response(user)
							@response[:message] = "Login successfull"
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
				render json: {status: "0", message: "Already Logged out/Invalid token"}
			end

		end

	end
end