module Spree
  class Api::V1::WishlistsController < Spree::Api::BaseController

    before_filter :find_user

    def index
      
      @products = []
      #@wishlist = []
      if @user.present? && @user.wishlists.present?
        @user.wishlists.each do |wish|
          @products.push(wish.variant.try(:product))
         # @wishlist.push(wish.id.to_s)
        end
        render json: {
          status: "1" ,
          message: "Wishlist Retrieve Successfully" ,
          #wishlist_id: @wishlist.as_json(),
          details: to_stringify_product_json(@products, @user, [])
        }
      else
        render json: {
          status: "0",
          message: "No item in wishlist"
        }
      end
    end

    def create
      if @user.present?
       # @wishlist = Spree::Wishlist.create(user_id: @user.id , variant_id: params[:wishlist][:variant_id])
        @wishlist  = Spree::Wishlist.new(wishlist_params.merge({user_id: @user.id}))
        if @wishlist.save
          render json: {
            status: 1 ,
            message: "Item added successfully to wishlist"
          }
        else
          render json: {
            status: 0,
            message: "Something Went Wrong"
          }
        end
      else
        render json: {
          status: 0,
          message: "User not Found"
        }
      end  
    end

    def destroy
      if @user.wishlists.where(variant_id: params[:id]).last.destroy
        render json: {
            status: 1 ,
            message: "Item deleted successfully from wishlist"
        } 
      else
         render json: {
            status: 0 ,
            message: "Item not deleted successfully from wishlist"
        }
      end

    end

    private

    def find_user
      @user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
    end    
  


    def wishlist_params
      params.require(:wishlist).permit(:variant_id, :user_id)
    end
  
  end
end