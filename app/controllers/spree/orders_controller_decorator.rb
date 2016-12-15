Spree::OrdersController.class_eval do 
  before_filter :process_paypal_express, only: :update
  before_filter :load_order, only: [:cancel, :ready_to_pick]
  skip_before_filter :authenticate_user, only: [:apply_coupon_code]

  include Spree::Api::ApiHelpers
  include Spree::Core::ControllerHelpers::Order

  def process_paypal_express
    if params[:paypal].blank? || params[:paypal][:payment_method_nonce].blank?
      # when user goes back from checkout, paypal express payments should be invalidated  to ensure standard checkout flow
      current_order.invalidate_paypal_express_payments
      return true
    end
    payment_method = Spree::PaymentMethod.find_by_id(params[:paypal][:payment_method_id])
    return true unless payment_method

    email = params[:order][:email]
    # when user goes back from checkout, order's state should be resetted to ensure paypal checkout flow
    current_order.state = 'cart'
    current_order.save_paypal_payment(payment_params)

    manage_paypal_addresses
    payment_method.push_order_to_state(current_order, 'address', email)
    current_order.remove_phone_number_placeholder

    redirect_to checkout_state_path("complete", paypal_email: email)
  end

  def order_placed
    @order = current_spree_user.orders.includes(line_items: [variant: [:option_values, :images, :product]], bill_address: :state, ship_address: :state).find_by_number!(params[:id])
  end

    def promotions_total
     (adjustments.eligible - adjustments.tax - adjustments.shipping).map(&:amount).sum
    end

    
	def populate
    order    = current_order(create_order_if_necessary: true)
    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].to_i
    options  = params[:options] || {}
    delivery_type = params[:delivery_type] || "home_delivery"

    # 2,147,483,647 is crazy. See issue #2695.
    if quantity.between?(1, 500)
      if quantity <= variant.total_on_hand
        begin
          order.contents.add(variant, quantity, options, delivery_type)
        rescue ActiveRecord::RecordInvalid => e
          error = e.record.errors.full_messages.join(", ")
        end
      else
       # error = 'Max Available: "#{variant.total_on_hand}"'
       error ="Max Quantity Available: " + variant.total_on_hand.to_s
      end
    else
      error = Spree.t(:please_enter_reasonable_quantity)
    end

    if error
      flash[:error] = error
      redirect_back_or_default(spree.root_path)
    else
      respond_with(order) do |format|
        if params[:bunch_cart]
          format.html { redirect_to :back, notice: "Successfully added into cart" }
        else
          format.html { redirect_to spree.root_path , notice: "Successfully added into cart" }
        end
      end
    end
  end

  # def apply_coupon_code
  #     find_order
  #     authorize! :update, @order, order_token
  #     @order.coupon_code = params[:coupon_code]
  #     @handler = PromotionHandler::Coupon.new(@order).apply
  #     status = @handler.successful? ? 200 : 422
  #     #status =  @handler.successful? ? "1" : "0"
  #     render json: {
  #       success: @handler.successful?,
  #       #status: status ,
  #       message: @handler.successful? ? "Coupon code successfully applied" : @handler.error.blank? ? "Please enter a coupon code" : @handler.error
  #     }
  # end

  def ready_to_pick
    if @order.present?
      @line_items = @order.line_items.where(id: params[:item_ids])
      @line_items.find_each {|line_item| line_item.update_attributes(delivery_state: params[:option])}
      if params[:option] == "out_for_delivery"
        UserMailer.notify_items_out_for_delivery(@line_items).deliver
      end
      redirect_to :back, notice: "Notified successfully."
    else
      redirect_to :back, notice: "Order not found"
    end
  end

    def cancel
      authorize! :update, @order, params[:token]
      @order.canceled_by(try_spree_current_user)
      #respond_with(@order, default_template: :show)
      redirect_to :back, notice: "Order canceled successfully."
    end

  private

    def load_order
      id = params[:id] || params[:order_id]
      @order = Spree::Order.find_by_number(id)
    end

end