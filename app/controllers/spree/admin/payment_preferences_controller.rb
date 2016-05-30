class Spree::Admin::PaymentPreferencesController < Spree::Admin::ResourceController

	before_filter :load_seller

	def index
		@payment_preference = @seller.payment_preference
	end

	private

		def load_seller
			@seller = Spree::User.find_by_id(params[:seller_id])
		end
		
end