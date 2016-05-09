class MerchantController < ApplicationController
	
	include Spree::Core::ControllerHelpers 
	helper Spree::BaseHelper
	helper Spree::OrdersHelper
	helper Spree::ProductsHelper
	helper Spree::StoreHelper
	helper Spree::TaxonsHelper
	
	def index
		@stores = @current_spree_user.try(:stores)
	end
end	