module Spree
	class Api::V1::SearchController < Spree::Api::BaseController
		
		def index
			@search = Sunspot.search(Spree::Product) do 
  			fulltext params[:q][:search] if params[:q] && params[:q][:search]
  		end
  		@products= @search.results

  		if @products.blank?
  			render json: {code: 0, message: "No Result Found "}
  		else
  			render json: {
  				status: 1, 
  				message: "Search Result",
  				details: @products.as_json({
        		only: [:sku, :name, :price, :id, :description],
       			methods: [:price, :stock_status, :total_on_hand, :average_ratings, :taxon_ids, :product_images],
       			include: [variants: {only: :id, methods: [:price, :option_name, :stock_status, :total_on_hand, :product_images]}]
     		 })
  			}
  		end
		end

		def filters
			@all_facets = Sunspot.search(Spree::Product) do
				facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval =>100 )
				facet(:brand_name)
				facet(:store_name)
			end

		price_facet = Array.new
		brand_facet = Array.new
		store_facet = Array.new

			@all_facets.facet(:price).rows.each do |price|
			 	price_facet.push(price.value.to_s)
			end

			@all_facets.facet(:store_name).rows.each do |store|
			 	store_facet.push(store.value.to_s)
			end

			@all_facets.facet(:brand_name).rows.each do |brand|
			 	brand_facet.push(brand.value.to_s)
		  end
		  
			
			render json: {
				status: 1,
				message: "Attribute List",
				attribute: [
					{
						name: "Brand",
						list: brand_facet.as_json()
					}.as_json,
					{
						name: "Store",
						list: store_facet.as_json()
					}.as_json,
					{
						name: "Price",
						list: price_facet.as_json()
					}.as_json
				]
			}
		end

	end
end
