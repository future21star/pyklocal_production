module Spree

	class Api::V1::RegistrationsController < Spree::Api::BaseController

		skip_before_filter :authenticate_user

		def create
			@user = Spree.user_class.new(user_params)
			if @user.save
      	respond_with(@user, :status => 201, :default_template => :show)
      else
      	respond_with(@user.errors)
      end
		end

		private

			def user_params
        params.require(:user).permit(permitted_user_attributes |
                                       [bill_address_attributes: permitted_address_attributes,
                                        ship_address_attributes: permitted_address_attributes])
      end

	end
end