Spree::HomeController.class_eval do

	before_filter :authenticate_spree_user!, only: [:shipping_addresses, :billing_addresses, :orders, :shipping_page] 

	def orders
		@orders = current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled") if spree_user_signed_in?
	end

  def new_store_application
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

end
