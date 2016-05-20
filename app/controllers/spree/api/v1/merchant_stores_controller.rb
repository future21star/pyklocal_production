module Spree
	class Api::V1::MerchantStoresController < Spree::Api::BaseController

		before_filter :load_store, only: [:update_location]
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

		private 

			def store_params
				params.require(:merchant_store).permit(:name, :active, :latitude, :longitude, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], store_users_attributes: [:spree_user_id, :store_id, :id])
			end

			def load_store
				slug = params[:id] || params[:merchant_store_id]
				@store = Merchant::Store.find_by_slug(slug)
			end

	end
end