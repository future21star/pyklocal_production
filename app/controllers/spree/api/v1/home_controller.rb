module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
	    @categories = Spree::Taxon.all
      @product = Spree::Product.all
      render json: {
        status: 1,
        message: "Home Screen",
        details:[{index: 0, title: "Top Banner",parent_category_id: 0,
          item_list: @categories.as_json({only: [:id]}) },
          {index: 1, title: "Today's Deal",
          item_list: @product.as_json({
            only: [:sku, :name, :price, :id, :description],
            methods: [:price, :stock_status, :total_on_hand, :average_ratings, :taxon_ids, :product_images],
            include: [variants: {only: :id, methods: [:price, :option_name, :stock_status, :total_on_hand, :product_images]}]
          })}
        ]
      }
    end
  end
end