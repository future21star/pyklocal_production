class Merchant::HomeController < Merchant::ApplicationController

	def index
		@stores = current_spree_user.pyklocal_stores
	end
	
end