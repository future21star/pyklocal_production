class Spree::ShopController < Spree::StoreController

  def index 
    @price_array = params[:q][:price].to_s if params[:q] && params[:q][:price]
    @all_facets = Sunspot.search(Spree::Product) do 
      with(:location).in_radius(params[:lat], params[:lng], params[:radius].to_i, bbox: true) if params[:lat].present? && params[:lng].present?
      facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
    end
    @search = Sunspot.search(Spree::Product) do 
      fulltext params[:search] if params[:q] && params[:q][:search]
      paginate(:page => params[:page], :per_page => 20)
      with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
      facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
      if params[:q] && params[:q][:price]
        any_of do 
          params[:q][:price].each do |price|
            with(:price, Range.new(*price.split("..").map(&:to_i)))
          end
        end
      end
    end
    @products = @search.results
    @taxons = Spree::Taxon.where.not(name:"categories") 
    @taxonomies = Spree::Taxonomy.includes(root: :children) 
    @store = Merchant::Store.all
  end

  def show 
    @taxons = Spree::Taxon.where.not(name:"categories")
    @products = Spree::Taxon.where(name: params[:id]).first.try(:products).page(params[:page]).per(16).order("created_at desc")    
  end

end