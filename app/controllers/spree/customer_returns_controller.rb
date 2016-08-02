class Spree::CustomerReturnsController < Spree::StoreController

  def index
    @customer_return_request = spree_current_user.customer_returns
    
  end

  def new
    if params[:order_number].blank?
      redirect_to :back, :params => @params 
    else
      @customer_return = Spree::CustomerReturn.new
      @order = Spree::Order.where(number: params[:order_number]).first
      @request_auth = @order.return_authorizations.last
      @inventoryunit = @order.inventory_units.last
    end

  end


  def create
    @customer_return = Spree::CustomerReturn.new(customer_returns_param.merge({user_id: current_spree_user.id}))
    p @customer_return.errors
    if @customer_return.save
      redirect_to customer_returns_path, notice: " Your request have been submitted"
    else
      redirect_to customer_returns_path, notice: "Request is already submitted"
    end
  end

  private

    def customer_returns_param
      params.require(:customer_return).permit(:number, :stock_location_id, :return_authorization_reason_id)
      
    end

end