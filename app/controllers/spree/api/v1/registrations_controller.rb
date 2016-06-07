module Spree

	class Api::V1::RegistrationsController < Spree::Api::BaseController

		skip_before_filter :authenticate_user
    include Spree::Api::SessionsHelper

		def create
			@user = Spree.user_class.new(user_params)
			if @user.save
      	@response = get_response(@user)
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

			def user_params
        params.require(:user).permit(permitted_user_attributes |
                                       [bill_address_attributes: permitted_address_attributes,
                                        ship_address_attributes: permitted_address_attributes])
      end

	end
end