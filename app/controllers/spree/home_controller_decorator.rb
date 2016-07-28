Spree::HomeController.class_eval do

	before_filter :authenticate_spree_user!, only: [:orders] 

	def index
    @search = Sunspot.search(Spree::Product) do
      with(:location).in_radius(session[:lat], session[:lng], 30.to_i, bbox: true) if session[:lat].present? && session[:lng].present?
      order_by(:sell_count, :desc)
    end 
		# @searcher = build_searcher(params.merge(include_images: true))
    # @products = @searcher.retrieve_products.includes(:possible_promotions)
    @products = @search.results
		@bag_categories = Spree::Taxon.where(name: "Bags").first.products
		@clothing_categories = Spree::Taxon.where(name: "Mugs").first.products
	end

	def orders
		@orders = current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled") if spree_user_signed_in?
	end

  def new_store_application
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

end