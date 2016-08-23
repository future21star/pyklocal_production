module Spree
	class Api::V1::PasswordController < Api::BaseController

		def create
			user = Spree::User.find_by_email(params[:email])
			unless user.blank?
				user.send_reset_password_instructions
				render json: {code: 1, message: "Link send successfully"}
			else
				@response = error_response
				@response[:message] = "Invalid email"
			end
		end
	end
end