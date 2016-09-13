module Spree
	class Api::V1::SearchController < Spree::Api::BaseController
		before_filter :perform_search, only: [:index]
		
		def index
  		@products = @search.results

  		if @products.blank?
  			render json: {
          code: "0", 
          message: "No Result Found "
        }
  		else
  			render json: {
  				status: "1", 
  				message: "Search Result",
  				details:  to_stringify_product_json(@products ,[])
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
				status: "1",
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

		private

		def perform_search
			 per_page = params[:q] && params[:q][:per_page] ? params[:q][:per_page] : 12
      @search = Sunspot.search(Spree::Product) do 
        fulltext params[:q][:search] if params[:q] && params[:q][:search]
        paginate(:page => params[:page], :per_page => per_page)
        with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
        facet(:price, :range => Spree::Product.min_price..Spree::Product.max_price, :range_interval => 100)
        facet(:brand_name)
        facet(:store_name)
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
          any_of do 
            params[:q][:price].each do |price|
              with(:price, Range.new(*price.split("..").map(&:to_i)))
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
end
