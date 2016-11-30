module Spree
	class Api::V1::HomeController < Spree::Api::BaseController
		
		def index
      if params[:token]
        @api_token = ApiToken.where(token: params[:token],expire: nil).last
 
        if @api_token
          @user = @api_token.user
          @search = Sunspot.search(Spree::Product) do
            with(:location).in_radius(session[:lat], session[:lng], 30.to_i, bbox: true) if session[:lat].present? && session[:lng].present?
            with(:buyable, :true)
            paginate(:page => 1, :per_page => 5)
            order_by(:sell_count, :desc)
          end 
          @products = @search.results
          @view_search = Sunspot.search(Spree::Product) do 
            order_by(:view_counter, :desc)
            with(:buyable, :true)
            paginate page: 1, per_page: 5
          end
          @most_viewed_products = @view_search.results
          #@top_images = Spree::CarouselImage.where("active = ? AND position != ? AND position != ?", true, "bottom", "middle" )
          @new_arrival = Spree::Product.all.where(buyable: true).limit(5).order('created_at DESC')
          @carousel_images = Spree::CarouselImage.where(is_static: false).active
          @top_static_images = Spree::StaticImage.where(is_static: true, position: "top").active.limit(2)
          @middle_static_images = Spree::StaticImage.where(is_static: true, position: "middle").active.limit(3)
          @bottom_static_image = Spree::StaticImage.where(is_static: true, position: "bottom").active.limit(1)
          @top_images = @carousel_images + @top_static_images
          @middle = Spree::StaticImage.where.not(position: "top").active
          render json: {
            status: "1",
            message: "Home Screen",
            cart_count:   @user.cart_count.to_s,
            details:[
              {
                index: "0", 
                title: "Top Banner",
                parent_category_id:"",
                view_type: "0",
                item_list:to_stringify_image(@top_images, [])
              },
              {
                index: "1", 
                title: "Best Seller",
                parent_category_id: "1",
                view_type: "1",
                item_list: to_stringify_product_json(@products, @user, [])
              } ,
              {
                index: "2", 
                title: "New Arrival",
                parent_category_id: "2",
                view_type: "1",
                item_list: to_stringify_product_json(@new_arrival, @user, [])
              },
              {
                index: "3", 
                title: "Banner",
                parent_category_id: "",
                view_type: "0",
                item_list: to_stringify_image(@middle , [])
              },
              {
                index: "4", 
                title: "Most Viewed",
                parent_category_id: "3",
                view_type: "1",
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
                with(:buyable, :true)
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
             @new_arrival = Spree::Product.all.where(buyable: true).order('created_at DESC').page(page).per(per_page)
              render json: {
                status: "1",
                message: "New Arrival",
                item_list: to_stringify_product_json(@new_arrival, @user, [])
              }
            elsif params[:id] == "3"
              @view_search = Sunspot.search(Spree::Product) do 
                order_by(:view_counter, :desc)
                with(:buyable, :true)
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
          banner_image_hash["static".to_sym] = banner_image.is_static.to_s
          unless banner_image.is_static == true
             banner_image_hash["category_id".to_sym] = banner_image.resource_id.to_s
          end
          values.push(banner_image_hash)
        end
        return values
      end

      
  end
end