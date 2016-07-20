module Spree
	class Api::V1::MerchantStoresController < Spree::Api::BaseController

		before_filter :load_store, only: [:update_location, :rate]
		before_filter :find_user, only: [:rate]
		# before_filter :check_for_purchased_item, only[:rate]
		skip_before_filter :authenticate_user

		def update_location
			if @store.update_attributes(store_params)
				render json: {
					success: true
				}
			else
				render json: {
					success: false,
					errors: @store.errors.full_messages.join(", ")
				}
			end
		end

		def rate
			if @user.user_store_ratings.where(store_id: @store.id).present?
				@user.user_store_ratings.where(store_id: @store.id).delete_all
			end
			@rating = @store.user_store_ratings.new(user_id: @user.id, comment: params[:comment], rating: params[:rating])
			if @rating.save
				render json: {
					success: true,
					message: "Submitted successfully",
					rating: (@store.user_store_ratings.sum(:rating) / @store.user_store_ratings.count).round(2)
				}
			else
				render json: {
					success: false,
					message: @rating.errors.full_messages.join(", ")
				}
			end
		end

		private 

			def store_params
				params.require(:merchant_store).permit(:name, :active, :latitude, :longitude, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], store_users_attributes: [:spree_user_id, :store_id, :id])
			end

			def load_store
				slug = params[:id] || params[:merchant_store_id]
				@store = Merchant::Store.find_by_slug(slug)
				render json: {success: false, message: "Store not found"} unless @store.present?
			end

			def find_user
				@user = Spree::User.where(id: params[:user_id]).first
				render json: {success: false, message: "User not found"} unless @user.present?
			end

			# def check_for_purchased_item
			# 	@user = find_user
			# 	@store = load_store
			# 	success = false
			# 	if @store && @user && @user.orders
			# 		@user.orders.each do |order|
			# 			if order.products.include?(@store.products)
			# 				success = true
			# 			end
			# 		end
			# 	end
			# 	render json: {success: false, message: "You need to purchase at least one product from this store"}
			# end

	end
end