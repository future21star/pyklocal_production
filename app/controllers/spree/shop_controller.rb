class Spree::ShopController < Spree::StoreController

  def index 
    @price_array = params[:q][:price].to_s if params[:q] && params[:q][:price]
    @all_facets = Sunspot.search(Spree::Product) do 
      with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
      facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
    end
    @search = Sunspot.search(Spree::Product) do 
      fulltext params[:q][:search] if params[:q] && params[:q][:search]
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
    @price_array = params[:q][:price].to_s if params[:q] && params[:q][:price]
    @all_facets = Sunspot.search(Spree::Product) do 
      with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
      with(:taxon_ids, Spree::Taxon.where(name: params[:id]).collect(&:id))
      facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
    end
    @search = Sunspot.search(Spree::Product) do 
      fulltext params[:q][:search] if params[:q] && params[:q][:search]
      paginate(:page => params[:page], :per_page => 20)
      with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
      facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
      with(:taxon_ids, Spree::Taxon.where(name: params[:id]).collect(&:id))
      if params[:q] && params[:q][:price]
        any_of do 
          params[:q][:price].each do |price|
            with(:price, Range.new(*price.split("..").map(&:to_i)))
          end
        end
      end
    end
    @products = @search.results
  end

end