module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
      if params[:token]
        @api_token = ApiToken.where(token: params[:token],expire: nil).last
 
        if @api_token
          @user = @api_token.user
          @search = Sunspot.search(Spree::Product) do
            with(:location).in_radius(session[:lat], session[:lng], 30.to_i, bbox: true) if session[:lat].present? && session[:lng].present?
            paginate(:page => 1, :per_page => 5)
            order_by(:sell_count, :desc)
          end 
          @products = @search.results
          @view_search = Sunspot.search(Spree::Product) do 
            order_by(:view_count, :desc)
            paginate page: 1, per_page: 5
          end
          @most_viewed_products = @view_search.results
          @new_arrival = Spree::Product.all.limit(5).order('created_at DESC')
          @carousel_images = Spree::CarouselImage.where(is_static: false).active
          @top_static_images = Spree::StaticImage.where(is_static: true, position: "top").active.limit(2)
          @middle_static_images = Spree::StaticImage.where(is_static: true, position: "middle").active.limit(3)
          @bottom_static_image = Spree::StaticImage.where(is_static: true, position: "bottom").active.limit(1)
          render json: {
            status: "1",
            message: "Home Screen",
            cart:   @user.cart_count.to_s,
            details:[
              {
                index: "0", 
                title: "Top Banner",
                parent_category_id:"",
                item_list: {
                    carousel_image: to_stringify_image(@carousel_images ,[]) ,
                    static_images:  to_stringify_image(@top_static_images ,[])
                  }
              },
              {
                index: "1", 
                title: "Best Seller",
                parent_category_id: "1",
                item_list: to_stringify_product_json(@products, @user, [])
              } ,
              {
                index: "2", 
                title: "New Arrival",
                parent_category_id: "2",
                item_list: to_stringify_product_json(@new_arrival, @user, [])
              },
              {
                index: "3", 
                title: "Banner",
                parent_category_id: "3",
                item_list: {
                  middle_banner: to_stringify_image(@middle_static_images),
                  bottom_banner: to_stringify_image(@bottom_static_image)
                }
              },
              {
                index: "4", 
                title: "Most Viewed",
                parent_category_id: "4",
                item_list: to_stringify_product_json(@most_viewed_products, @user, [])
              }
            ]
          }
        else
          render json:{
            status: "0",
            message: "Invalid Token Or User Already Logout"
          }
        end
      else
        render json:{
          status: "0",
          message: "Token Missing"
        }
      end
    end

      def show
        if params[:token]
          @api_token = ApiToken.where(token: params[:token],expire: nil).last
          if @api_token
            per_page = params[:per_page] ? params[:per_page] : 20
            page = params[:page] ? params[:page] : 1
            @user = @api_token.user
            if params[:id] == "1"
              @search = Sunspot.search(Spree::Product) do
                with(:location).in_radius(session[:lat], session[:lng], 30.to_i, bbox: true) if session[:lat].present? && session[:lng].present?
                paginate(:page => page, :per_page => per_page)
                order_by(:sell_count, :desc)
              end 
              @products = @search.results
              render json: {
                status: "1",
                message: "Best Seller",
                item_list: to_stringify_product_json(@products, @user, [])
              }
            elsif params[:id] == "2"
             @new_arrival = Spree::Product.all.order('created_at DESC').page(page).per(per_page)
              render json: {
                status: "1",
                message: "New Arrival",
                item_list: to_stringify_product_json(@new_arrival, @user, [])
              }
            elsif params[:id] == "4"
              @view_search = Sunspot.search(Spree::Product) do 
                order_by(:view_count, :desc)
                paginate(:page => page, :per_page => per_page)
              end
              @most_viewed_products = @view_search.results
              render json: {
                status: "1",
                message: "Most Viewed",
                item_list: to_stringify_product_json(@most_viewed_products, @user, [])
              }
            else
              render json:{
                status: "0",
                message: "Invalid Category Id"
              }
            end
          else
            render json:{
              status: "0",
              message: "Invalid Token Or User Already Logout"
            }
          end
        else
          render json:{
              status: "0",
              message: "Token Missing"
            }
        end
      end

    private

      def to_stringify_image obj , values = []
        obj.each do |banner_image|
          banner_image_hash = Hash.new
          banner_image_hash["id".to_sym] = banner_image.id.to_s
          banner_image_hash["image".to_sym] = banner_image.image.url.to_s
          values.push(banner_image_hash)
        end
        return values
      end

      
  end
end