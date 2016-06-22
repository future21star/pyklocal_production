class Spree::ShopController < Spree::StoreController

  def index 
    @search = Sunspot.search(Spree::Product) do 
      fulltext params[:search] if params[:search]
      paginate(:page => params[:page], :per_page => 20)
      with(:location).in_radius(params[:lat], params[:lng], params[:radius].to_i, bbox: true) if params[:lat].present? && params[:lng].present?
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