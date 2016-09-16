module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
	    @categories = Spree::Taxon.all
      @product = Spree::Product.all
      render json: {
        status: "1",
        message: "Home Screen",
        details:[
          {
            index: "0", 
            title: "Top Banner",
            item_list: to_strigify_categories(@categories ,[]) 
          },
          {
            index: "1", 
            title: "Today's Deal",
            item_list: to_stringify_product_json(@product , [])
          }
        ]
      }
    end

    private

      def to_strigify_categories obj , values = []
        obj.each do |category|
          category_hash = Hash.new
          category_hash["id".to_sym] = category.id.to_s
          values.push(category_hash)
        end
        return values
      end
  end
end