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
    @view_search = Sunspot.search(Spree::Product) do 
      order_by(:view_count, :desc)
      paginate page: 1, per_page: 20
    end
    @most_viewed_products = @view_search.results
    @new_arrival = Spree::Product.all.limit(30).order('created_at DESC')
		@bag_categories = Spree::Taxon.where(name: "Bags").first.try(:products)
		@clothing_categories = Spree::Taxon.where(name: "Mugs").first.try(:products)
    @carousel_images = Spree::CarouselImage.where(is_static: false).active
    @static_images = Spree::StaticImage.where(is_static: true).active.limit(2)
	end

	def orders
		params[:q] ||= {}
    params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
    @show_only_completed = params[:q][:completed_at_not_null] == '1'
    params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'
    params[:q][:completed_at_not_null] = '' unless @show_only_completed

    # As date params are deleted if @show_only_completed, store
    # the original date so we can restore them into the params
    # after the search
    created_at_gt = params[:q][:created_at_gt]
    created_at_lt = params[:q][:created_at_lt]

    params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

    if params[:q][:created_at_gt].present?
      params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
    end

    if params[:q][:created_at_lt].present?
      params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
    end

    if @show_only_completed
      params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
      params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
    end

    @search = current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled").ransack(params[:q])

    # lazy loading other models here (via includes) may result in an invalid query
    # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
    # see https://github.com/spree/spree/pull/3919
    @orders = @search.result(distinct: true).
      page(params[:page]).
      per(params[:per_page] || Spree::Config[:orders_per_page])

    # Restore dates
    params[:q][:created_at_gt] = created_at_gt
    params[:q][:created_at_lt] = created_at_lt
	end

  def new_store_application
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

end