Spree::CheckoutController.class_eval do

  before_action :before_address

	def before_address
    if current_spree_user
      if current_spree_user.try(:address).blank?
        if @order.try(:ship_address).present? && @order.try(:bill_address).present?
          @order.ship_address = @order.ship_address 
          @order.bill_address = @order.bill_address 
        elsif current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled").present?
          @order.ship_address = current_spree_user.orders.where("state = ? OR state = ?", "complete", "canceled").last.bill_address
          @order.bill_address = current_spree_user.orders.where("state = ? OR state =?", "complete", "canceled").last.ship_address
        elsif current_spree_user.try(:ship_address).present? && current_spree_user.try(:bill_address).present?
          @order.ship_address =  current_spree_user.ship_address
          @order.bill_address =  current_spree_user.bill_address
        else
      		@order.ship_address = Spree::Address.build_default
      		@order.bill_address = Spree::Address.build_default
        end
        if params[:is_existing]
          @order.attributes = {is_existing: params[:is_existing]}
        end
    	else
    	  @order.ship_address = current_spree_user.address
    	  @order.bill_address = current_spree_user.address
        if params[:is_existing]
          @order.attributes = {is_existing: params[:is_existing]}
        end
    	end
    end
	end
end