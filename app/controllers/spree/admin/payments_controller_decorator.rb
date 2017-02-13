module Spree
	module Admin
		PaymentsController.class_eval do 

			def index
				@payments = @order.payments.includes(refunds: :reason)
        @refunds = @payments.flat_map(&:refunds)
        @customer_refunds = @order.refunds
				p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
				p  @customer_refunds
        redirect_to new_admin_order_payment_url(@order) if @payments.empty?
			end
			
		end
	end
end