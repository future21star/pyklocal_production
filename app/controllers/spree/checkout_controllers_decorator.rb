# Spree::CheckoutController.class_eval do

#   # before_action :before_address
# 	# def before_address
#  #    if current_spree_user.try(:address).blank?
#  #        @order.ship_address = @order.ship_address ||  Spree::Address.build_default
#  #        @order.bill_address = @order.bill_address || Spree::Address.build_default 
#  #      if params[:is_existing]
#  #        @order.attributes = {is_existing: params[:is_existing]}
#  #      end
#  #  	else
#  #  	  @order.ship_address = current_spree_user.address.dup
#  #      @order.bill_address = current_spree_user.address.dup
#  #    end
#  #  end

# end