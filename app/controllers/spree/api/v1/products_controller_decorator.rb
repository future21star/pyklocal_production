module Spree
  Api::V1::ProductsController.class_eval do 

    skip_before_filter :authenticate_user, only: [:rate_and_comment]
    before_filter :find_user, only: [:rate_and_comment]
    before_filter :get_product, only: [:rate_and_comment]

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