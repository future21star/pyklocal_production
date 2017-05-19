Spree::HomeController.class_eval do

	before_filter :authenticate_spree_user!, only: [:orders] 

	def index
    @search = Sunspot.search(Spree::Product) do
      with(:location).in_radius(session[:lat], session[:lng], 30.to_i, bbox: true) if session[:lat].present? && session[:lng].present?
      with(:visible, :true)
      with(:buyable, true)
      order_by(:sell_count, :desc)
    end 
		# @searcher = build_searcher(params.merge(include_images: true))
  #   @products = @searcher.retrieve_products.includes(:possible_promotions)
    # @search = Sunspot.search(Spree::Product)
    @products = @search.results
    @view_search = Sunspot.search(Spree::Product) do 
      order_by(:view_counter, :desc)
      with(:visible, :true)
      with(:buyable, true)
      paginate page: 1, per_page: 20
    end
     @most_viewed_products = @view_search.results
      #@most_viewed_products =  Spree::Product.all.where(buyable: true).limit(30).order('view_counter desc')
    # @new_arrival = Spree::Product.all.where(buyable: true).limit(30).order('created_at DESC')
    @search_new_arrival = Sunspot.search(Spree::Product) do
      # with(:buyable, :true)
      with(:visible, :true)
      with(:buyable, true)
      order_by(:created_at, :desc)
      paginate page: 1, per_page: 30
    end
    @new_arrival = @search_new_arrival.results
		@bag_categories = Spree::Taxon.root.children.first.try(:products)
		@clothing_categories = Spree::Taxon.root.children.last.try(:products)
    @carousel_images = Spree::CarouselImage.where(is_static: false).active
    @info_commercials = Spree::InfoCommercial.all
    @top_static_images = Spree::StaticImage.where(is_static: true, position: "top").active.limit(2)
    @middle_static_images = Spree::StaticImage.where(is_static: true, position: "middle").active.limit(3)
    @bottom_static_image = Spree::StaticImage.where(is_static: true, position: "bottom").active.last
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


  def refund
    page = params[:page].present? ? params[:page] : 1
   
    @all_refunds = Spree::CustomerReturnItem.where("status = ?" ,"refunded").joins(:order).where(spree_orders:{user_id: current_spree_user.id}).order("created_at desc")
    @refunds = Kaminari.paginate_array(@all_refunds).page(page).per(20)
  end
  
  def new_store_application
    @user = Spree::User.new
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

end
