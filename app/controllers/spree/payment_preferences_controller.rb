class Spree::PaymentPreferencesController < Spree::StoreController

	before_filter :authenticate_spree_user!
	before_filter :find_payment_preferences, only: [:edit, :update, :destroy]

	def index
		@payment_preference = current_spree_user.payment_preference
		if @payment_preference.blank?
			@payment_preference = Spree::PaymentPreference.new()
		end
	end

	def edit
		
	end

	def create
		@payment_preference = Spree::PaymentPreference.new(payment_preference_params.merge(user_id: current_spree_user.id))
		if @payment_preference.save
			redirect_to spree.payment_preferences_path, notice: "Successfully saved."
		else
			render action: 'index'
		end
	end

	def update
		if @payment_preference.update_attributes(payment_preference_params)
			redirect_to spree.payment_preferences_path, notice: "Successfully updated."
		else
			render action: 'edit'
		end
	end

	def destroy
		@payment_preference_params.destroy
		redirect_to spree.payment_preferences_path, notice: "Successfully deleted."
	end

	private

		def find_payment_preferences
			@payment_preference = Spree::PaymentPreference.find_by_id(params[:id])
		end

		def payment_preference_params
			params.require(:payment_preference).permit(:user_id, :a_c_no, :payee_name, :bank_name, :swift_code, :routing_number)
		end

end