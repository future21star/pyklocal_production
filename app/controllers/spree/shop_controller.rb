class Spree::ShopController < Spree::StoreController

	def index
		
		@products = Spree::Product.all
		@taxons = Spree::Taxon.where.not(name:"categories")
		@taxonomies = Spree::Taxonomy.includes(root: :children)


	end

	def show 
		@taxons = Spree::Taxon.where.not(name:"categories")
		@products = Spree::Taxon.where(name: params[:id]).first.products
   	
	end

end