module Spree
  Api::V1::ProductsController.class_eval do 

    skip_before_filter :authenticate_user, only: [:rate_and_comment]
    before_filter :find_user, only: [:rate_and_comment]
    before_filter :get_product, only: [:rate_and_comment]

    def index
      if params[:category_id]
        @taxon = Spree::Taxon.where(id: params[:category_id]).first
        if @taxon
          @products = is_pagination_require ? @taxon.products.paginate(:page => params[:page], :per_page => @per_page ): @taxon.products
          unless @products.blank?
            render json: {
              status: "1",
              message: "Home Screen",
              category_id: @taxon.id.to_s,
              total_count: @products.count.to_s,
              details: to_stringify_product_json(@products ,[])
            }
          else
            render json: {
              status: "0",
              message: "No product found in this category"
            }
          end
        else
          render json: {
            status: "0",
            message: "Invalid Category Id"
          }
        end
      else
        @products = is_pagination_require ? Spree::Product.all.where(buyable: true).paginate(:page => params[:page], :per_page => @per_page) : Spree::Product.all
        render json: {
          status: "1",
          message: "Home Screen",
          total_count: @products.count.to_s,
          details: to_stringify_product_json(@products,  [])
        }
      end
    end

    def show
      if params[:token]
        @api_token = ApiToken.where(token: params[:token],expire: nil).last
        unless @api_token.blank?
          @user = @api_token.user
          @product = Spree::Product.where(id: params[:id])
          if @product
            render json: {
              status: "1" ,
              message: "Product Detail",
              details: to_stringify_product_json(@product, @user, [])
            }
          else
            render json: {
              status: "0",
              message: "Invalid Product Id"
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
      

    def rate_and_comment
      @rating = Rating.new(user_id: @user.id, rateable_id: @product.id, rateable_type: "Spree::Product", rating: params[:rating]) if params[:rating].present?
      @comment = Comment.new(user_id: @user.id, commentable_id: @product.id, commentable_type: "Spree::Product", comment: params[:comment]) if params[:comment].present?
      if @rating.present? && @comment.present?
        if @rating.save && @comment.save
          render json: {
            success: true,
            message: "Submitted successfully",
            rating: (@product.ratings.sum(:rating) / @product.ratings.count).round(2)
          }
        else
          render json: {
            success: false,
            message: [@rating.errors.full_messages.join(", "), @comment.errors.full_messages.join(", ")].join(" ")
          }
        end
      else
        render json: {
          success: false,
          message: "Rating and comment both are required fields"
        }
      end          
    end

    private

      def is_pagination_require
        if params[:page]
          @per_page = params[:per_page] ? params[:per_page] : 12
        else
         false
        end
      end

      def get_product
        @product = Spree::Product.find_by_slug(params[:product_id])
        render json: {success: false, message: "Product not found"} if @product.blank?
      end

      def find_user
        @user = Spree::User.find_by_spree_api_key(params[:user_id])
        render json: {success: false, message: "User not found, you need to login/signup first"} if @user.blank?
      end
      
  end
end
