Spree::HomeController.class_eval do

	before_filter :authenticate_spree_user!, only: [:shipping_addresses, :billing_addresses, :orders, :shipping_page] 


	def orders
		@orders = current_spree_user.orders.where(state: "complete")if spree_user_signed_in?
	end



end
