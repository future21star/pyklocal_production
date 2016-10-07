module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
      if params[:token]
        per_page = params[:per_page] ? params[:per_page] : 12
        page = params[:page] ? params[:page] : 1
        @api_token = ApiToken.where(token: params[:token]).last
        @user = @api_token.user
  	    @banner_images = Spree::CarouselImage.where(active: true)
        @product = Spree::Product.all.page(page).per(per_page)
        render json: {
          status: "1",
          message: "Home Screen",
          details:[
            {
              index: "1", 
              title: "Top Banner",
              item_list: to_stringify_banner_image(@banner_images ,[]) 
            },
            {
              index: "2", 
              title: "Today's Deal",
              cart:   @user.cart_count.to_s,
              item_list: to_stringify_product_json(@product, @user, [])
            }
          ]
        }
      else
        reder json:{
          status: "0",
          message: "Token Missing"
        }
      end
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