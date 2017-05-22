class Spree::ShopController < Spree::StoreController

    # before_filter :load_all_facets, only: [:index, :show]
    before_filter :perform_search, only: [:index, :show]

  def index 
    @price_selected = params[:q][:price]
    @brand_selected = params[:q][:brand]
    @store_selected = params[:q][:store]
    @category_selected = params[:q][:categories]
    p @price_selected
    # @store_selected = params[:]
    @price_array = params[:q][:price].to_s if params[:q] && params[:q][:price] && params[:q][:price].kind_of?(Array)
    @products = @search.results
    @taxons = Spree::Taxon.where.not(name: "categories") 
    @taxonomies = Spree::Taxonomy.includes(root: :children) 
    @store = Merchant::Store.all
  end

  def show 
    @taxon_name = params[:id]
    @price_array = params[:q][:price].to_s if params[:q] && params[:q][:price]
    @products = @search.results
  end

  private 

    def load_all_facets
      @all_facets = Sunspot.search(Spree::Product) do 
        fulltext "*#{params[:q][:search]}*"  if params[:q] && params[:q][:search]
        if params[:q] && params[:q][:category]
          with(:taxon_name, params[:q][:category])
        end
        # if params[:q] && params[:q][:categories]
        #   any_of do 
        #     params[:q][:categories].each do |category|
        #       with(:taxon_name, category)
        #     end
        #   end
        # end
        # if params[:q] && params[:q][:brand]
        #   any_of do 
        #     params[:q][:brand].each do |brand|
        #       with(:brand_name, brand)
        #     end
        #   end
        # end
        # if params[:q] && params[:q][:store]
        #   any_of do 
        #     params[:q][:store].each do |store|
        #       with(:store_name, store)
        #     end
        #   end
        # end
        # if params[:q] && params[:q][:price]
        #   any_of do 
        #     params[:q][:price].each do |price|
        #       with(:price, Range.new(*price.split("..").map(&:to_i)))
        #     end
        #   end
        # end
        with(:buyable, :true)
        with(:visible, :true)
        with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
        with(:taxon_ids, Spree::Taxon.where(permalink: params[:id]).collect(&:id)) if params[:id].present?
        facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
        facet(:brand_name)
        facet(:store_name)
        facet(:taxon_name)
        if (params[:q] && params[:q][:sort_by]) && (params[:q][:sort_by] == "Highest Price")
          order_by(:price, :desc)
        end
        if (params[:q] && params[:q][:sort_by]) && (params[:q][:sort_by] == "Lowest Price")
          order_by(:price, :asc) if params[:q] && params[:q][:sort_by]
        end
      end
    end

    def perform_search
      per_page = params[:q] && params[:q][:per_page] ? params[:q][:per_page] : 12
      @search = Sunspot.search(Spree::Product) do 
        fulltext "*#{params[:q][:search]}*" if params[:q] && params[:q][:search]
        paginate(:page => params[:page], :per_page => per_page)
        if params[:q] && params[:q][:category]
          with(:taxon_name, params[:q][:category])
        end
        with(:buyable, :true)
        with(:visible, :true)
        with(:taxon_ids, Spree::Taxon.where(permalink: params[:id]).collect(&:id)) if params[:id].present?
        with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
        facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
        facet(:brand_name)
        facet(:store_name)
        facet(:taxon_name)

        if params[:q] && params[:q][:categories]
          any_of do 
            params[:q][:categories].each do |category|
              with(:taxon_name, category)
            end
          end
        end
        if params[:q] && params[:q][:brand]
          any_of do 
            params[:q][:brand].each do |brand|
              with(:brand_name, brand)
            end
          end
        end
        if params[:q] && params[:q][:store]
          any_of do 
            params[:q][:store].each do |store|
              with(:store_name, store)
            end
          end
        end
        if params[:q] && params[:q][:price]
          if params[:q][:price].kind_of?(Array)
            any_of do 
              params[:q][:price].each do |price|
                with(:price, Range.new(*price.split("..").map(&:to_i)))
              end
            end
          end
        end
        if (params[:q] && params[:q][:sort_by]) && (params[:q][:sort_by] == "Highest Price")
          order_by(:price, :desc)
        end
        if (params[:q] && params[:q][:sort_by]) && (params[:q][:sort_by] == "Lowest Price")
          order_by(:price, :asc) if params[:q] && params[:q][:sort_by]
        end
      end
    end

end