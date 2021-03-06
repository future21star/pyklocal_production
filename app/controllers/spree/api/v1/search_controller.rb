module Spree
	class Api::V1::SearchController < Spree::Api::BaseController
		before_filter :perform_search, only: [:index]
    before_filter :load_all_facets, only: [:index]
    
		def index
      @api_token = ApiToken.where(token: params[:q][:token]).last 
      @all_facets = []
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
          @products = @search_result
    			render json: {
    				status: "1", 
    				message: "Search Result",
            cart_count: @user.cart_count.to_s,
            number_of_pages: @search_result.total_pages.to_s,
            total_product: @search.total.to_s,
            attributes: to_stringify_attribute_json(@all_facets, []),
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

    def to_stringify_attribute_json attr_obj, values = []
      if attr_obj.present?
        price_facet = Array.new
        brand_facet = Array.new
        store_facet = Array.new

        Hash price_facet_hash = Hash.new
        Hash brand_facet_hash = Hash.new
        Hash store_facet_hash = Hash.new

        @all_facets.facet(:price).rows.each do |price|
          price_facet.push(price.value.to_s)
        end

        @all_facets.facet(:store_name).rows.each do |store|
          store_facet.push(store.value.to_s)
        end

        @all_facets.facet(:brand_name).rows.each do |brand|
          brand_facet.push(brand.value.to_s)
        end
          brand_facet_hash["name".to_sym] = "brand"
          brand_facet_hash["list".to_sym] = brand_facet.as_json()
          store_facet_hash["name".to_sym] = "store"
          store_facet_hash["list".to_sym] = store_facet.as_json()
          price_facet_hash["name".to_sym] = "price"
          price_facet_hash["list".to_sym] = price_facet.as_json()
          values.push(brand_facet_hash)
          values.push(store_facet_hash)
          values.push(price_facet_hash)
      end
      return values
    end


    def load_all_facets
      if params[:page] == "1" && params[:filter_apply] == "0"
        @all_facets = Sunspot.search(Spree::Product) do 
          fulltext params[:q][:search] if params[:q] && params[:q][:search]
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
            any_of do 
              params[:q][:price].each do |price|
                with(:price, Range.new(*price.split("..").map(&:to_i)))
              end
            end
          end
          with(:buyable, true)
          with(:visible, true)
          with(:total_on_hand).greater_than(0)
          with(:hidden, false)
          facet(:price, :range => 0..100000, :range_interval => 100)
          with(:taxon_ids, Spree::Taxon.where(permalink: params[:id]).collect(&:id)) if params[:id].present?
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
    end


		def perform_search
			per_page = params[:q] && params[:q][:per_page] ? params[:q][:per_page] : 12
      @search = Sunspot.search(Spree::Product) do 
        #p params[:q].present? && params[:q][:id].blank?
        # fulltext params[:q][:search] if params[:q] && params[:q][:search] != "\"\""
        fulltext "*#{params[:q][:search]}*" if params[:q] && params[:q][:search] != "" && params[:q][:search] !=  nil
        paginate(:page => params[:page], :per_page => per_page)
        with(:location).in_radius(params[:q][:lat], params[:q][:lng], params[:q][:radius].to_i, bbox: true) if params[:q] && params[:q][:lat].present? && params[:q][:lng].present?
        with(:buyable, true)
        with(:visible, true)
        with(:hidden, false)
        with(:total_on_hand).greater_than(0)
        with(:store_id, params[:q][:store_id]) if params[:q] && params[:q][:store_id] != "" && params[:q][:store_id] != nil
        with(:taxon_ids, params[:q][:id]) if params[:q] && params[:q][:id] != "" && params[:q][:id] != nil
        facet(:price, :range => 0..100000, :range_interval => 100)
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
        if (params[:q] && params[:q][:parent_category_id]) && (params[:q][:parent_category_id] == "1")
          order_by(:sell_count, :desc)
        end
        if (params[:q] && params[:q][:parent_category_id]) && (params[:q][:parent_category_id] == "2")
          order_by(:created_at, :desc) 
        end
        if (params[:q] && params[:q][:parent_category_id]) && (params[:q][:parent_category_id] == "3")
          order_by(:view_counter, :desc) 
        end
      end
    end
		

	end
end
