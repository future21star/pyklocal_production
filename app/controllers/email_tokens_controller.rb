class EmailTokensController < ApplicationController

	include Spree::Core::ControllerHelpers
	helper Spree::BaseHelper
	helper Spree::CheckoutHelper
	helper Spree::OrdersHelper
	helper Spree::ProductsHelper
	helper Spree::StoreHelper
	helper Spree::TaxonsHelper

	def edit_store
		email_token = EmailToken.create(token: SecureRandom.hex(10).upcase, resource_id: params[:id], resource_type: params[:type], user_id: current_spree_user.id)
		UserMailer.edit_store(current_spree_user, email_token.resource, email_token.token).deliver if (params[:type] == "PyklocalStore")
		redirect_to merchant_store_url(email_token.resource), notice: "Please check your email for further instruction"
	end

end
