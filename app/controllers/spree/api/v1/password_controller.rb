module Spree
	class Api::V1::PasswordController < Api::BaseController

		skip_before_filter :authenticate_user
		def create
			user = Spree::User.find_by_email(params[:email])
			unless user.blank?
				begin
					user.send_reset_password_instructions
					render json: {status: "1", message: "Link send successfully"}
				rescue Exception => e
					render json: { status: "0" ,message: "Something went wrong" , Error: e.message.to_s }
				end
			else
				render json: {status: "0", message: "Invalid email"}
			end
		end
	end
end