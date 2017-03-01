module Spree
  class Api::V1::WishlistsController < Spree::Api::BaseController

    before_filter :find_user

    def index
      @products = []
      begin
        if @user.present? && @user.wishlists.present?
          @user.wishlists.order("created_at desc").each do |wish|
            unless wish.variant.blank?
              @products.push(wish.variant.try(:product))
            else
              wish.delete
            end
          end
          render json: {
            status: "1" ,
            message: "Wishlist Retrieve Successfully" ,
            details: to_stringify_product_json(@products, @user, [])
          }
        else
          render json: {
            status: "0",
            message: "No item in wishlist"
          }
        end
      rescue Exception => e
        render json:{
          status: "0",
          error: e.message.to_s
        }
      end
    end

    def create
      begin
        if @user.present?
         # @wishlist = Spree::Wishlist.create(user_id: @user.id , variant_id: params[:wishlist][:variant_id])
          if Spree::Variant.exists?(params[:wishlist][:variant_id])
            unless @user.wishlists.collect(:variant_id).include?(params[:wishlist][:variant_id].to_i)
              @wishlist  = Spree::Wishlist.new(wishlist_params.merge({user_id: @user.id}))
              if @wishlist.save
                render json: {
                  status: "1" ,
                  message: "Item added successfully to wishlist"
                }
              else
                render json: {
                  status: "0",
                  message: "Something Went Wrong"
                }
              end
            else
              render json: {
                status: "0",
                message: "Product already present in wishlist"
              }
            end
          else
            render json: {
              status: "0",
              message: "No variant exist with this id"
            }
          end
        else
          render json: {
            status: "0",
            message: "User not Found"
          }
        end  
      rescue Exception => e
        render json:{
          status: "0",
          error: e.message.to_s
        }
      end 
    end

    def destroy
      begin
        if Spree::Variant.exists?(params[:id])
          if @user.wishlist_variant_ids.include? params[:id].to_i
            if @user.wishlists.where(variant_id: params[:id]).last.destroy
              render json: {
                  status: "1" ,
                  message: "Item deleted successfully from wishlist"
              } 
            else
               render json: {
                  status: "0" ,
                  message: "Item not deleted successfully from wishlist"
              }
            end
          else
            render json:{
              status: "0",
              message: "No wishlist exist with this variant id"
            }
          end
        else
          render json: {
                status: "0",
                message: "No variant exist with this id"
            } 
        end
      rescue Exception => e
        render json:{
          status: "0",
          error: e.message.to_s
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