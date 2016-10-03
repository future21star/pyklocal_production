module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
	    @banner_images = Spree::CarouselImage.where(active: true)
      @product = Spree::Product.all
      render json: {
        status: "1",
        message: "Home Screen",
        details:[
          {
            index: "0", 
            title: "Top Banner",
            item_list: to_stringify_banner_image(@banner_images ,[]) 
          },
          {
            index: "1", 
            title: "Today's Deal",
            item_list: to_stringify_product_json(get_random_product , [])
          }
        ]
      }
    end

    private

      def to_stringify_banner_image obj , values = []
        obj.each do |banner_image|
          banner_image_hash = Hash.new
          banner_image_hash["id".to_sym] = banner_image.id.to_s
          banner_image_hash["image".to_sym] = banner_image.image.url.to_s
          values.push(banner_image_hash)
        end
        return values
      end

      def get_random_product
        loop do
          @product = Spree::Product.where(id: Random.new.rand(Spree::Product.first.id..Spree::Product.last.id))
          if @product
            return @product
            break;
          end
        end
      end
  end
end