class Spree::Admin::PaymentHistoriesController < Spree::Admin::ResourceController

	before_filter :load_seller
	before_filter :find_payment_history, only: [:edit, :update, :destroy]

	def index
		@payment_histories = @seller.payment_histories.order('created_at desc')
	end

	def new
		@payment_history = @seller.payment_histories.new
	end

	def edit
		
	end

	def create
		if @seller.amount_due.present?
			@payment_history = @seller.payment_histories.new(payment_history_params)
			if @payment_history.save
				redirect_to spree.admin_seller_payment_histories_path, notice: "Successfully saved"
			else
				render :new
			end
		else
			redirect_to :back , notice: "No Item is sold by this vendor"
		end
	end

	def update
		if @payment_history.update_attributes(payment_history_params)
			flash.now[:success] = Spree.t(:payment_history_updated)
		end

		render :edit
	end

	def destroy
		@payment_history.destroy
		redirect_to spree.admin_seller_payment_histories_path, notice: "Successfully deleted"
	end

	private

		def load_seller
			@seller = Spree::User.find_by_id(params[:seller_id])
		end

		def find_payment_history
			@payment_history = Spree::PaymentHistory.find_by_id(params[:id])
		end

		def payment_history_params
			params.require(:payment_history).permit(:user_id, :amount, :transaction_number, :amount_due)
		end

end