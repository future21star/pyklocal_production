module Spree
	class Api::V1::SearchController < Spree::Api::BaseController
		before_filter :perform_search, only: [:index]
		
		def index
      @api_token = ApiToken.where(token: params[:q][:token]).last 
      if @api_token
        per_page = params[:q] && params[:q][:per_page] ? params[:q][:per_page] : 12
        page = params[:page] ? params[:page] : 1
        @user = @api_token.user
    		@search_result = @search.results
    		if @search_result.blank?
    			render json: {
            status: "0", 
            message: "No Product Found"
          }
    		else
          #@products = @search_result.page(page).per(per_page)
          @products = Spree::Product.where(id: @search.results.map(&:id), buyable: true).page(page).per(per_page)
    			render json: {
    				status: "1", 
    				message: "Search Result",
            cart_count: @user.cart_count.to_s,
            number_of_pages: (@search_result.count / per_page.to_f).ceil().to_s,
            total_product: @search_result.count.to_s,
    				details:  to_stringify_product_json(@products , @user ,[])
    			}
    		end
      else
        render json: {
            status: "0", 
            message: "Invalid Token"
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
        p "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
        p  params[:q][:id].present?
        p  params[:q][:id].blank?
        p params[:q][:id].blank?
        p params[:q][:search]
        p params[:q][:id] == "\"\""
        #p params[:q].present? && params[:q][:id].blank?
        # fulltext params[:q][:search] if params[:q] && params[:q][:search] != "\"\""
        fulltext params[:q][:search] if params[:q] && params[:q][:search]
        #paginate(:page => params[:page], :per_page => per_page)
        with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
        with(:buyable, :true)
        with(:store_id, params[:q][:store_id]) if params[:q] && params[:q][:store_id]
        with(:taxon_ids, params[:q][:id]) if params[:q] && params[:q][:id]
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
        if (params[:q] && params[:q][:sort_type]) && (params[:q][:sort_type] == "1")
          order_by(:price, :desc)
        end
        if (params[:q] && params[:q][:sort_type]) && (params[:q][:sort_type] == "2")
          order_by(:price, :asc) if params[:q] && params[:q][:sort_type]
        end
      end
    end
		

	end
end
