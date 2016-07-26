Spree::OrdersController.class_eval do 

  before_filter :load_order, only: [:cancel, :ready_to_pick]

  def order_placed
    @order = current_spree_user.orders.includes(line_items: [variant: [:option_values, :images, :product]], bill_address: :state, ship_address: :state).find_by_number!(params[:id])
  end

	def populate
    order    = current_order(create_order_if_necessary: true)
    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].to_i
    options  = params[:options] || {}
    delivery_type = params[:delivery_type] || "home_delivery"

    # 2,147,483,647 is crazy. See issue #2695.
    if quantity.between?(1, 2_147_483_647)
      begin
        order.contents.add(variant, quantity, options, delivery_type)
      rescue ActiveRecord::RecordInvalid => e
        error = e.record.errors.full_messages.join(", ")
      end
    else
      error = Spree.t(:please_enter_reasonable_quantity)
    end

    if error
      flash[:error] = error
      redirect_back_or_default(spree.root_path)
    else
      respond_with(order) do |format|
        format.html { redirect_to cart_path }
      end
    end
  end

  def ready_to_pick
    if @order.present?
      @line_items = @order.line_items.where(id: params[:item_ids])
      @line_items.find_each {|line_item| line_item.update_attributes(delivery_state: params[:option])}
      redirect_to :back, notice: "Notified successfully."
    else
      redirect_to :back, notice: "Order not found"
    end
  end

  def cancel
    @order.canceled_by(try_spree_current_user)
    redirect_to :back, notice: "Order canceled"
  end

  private

    def load_order
      id = params[:id] || params[:order_id]
      @order = Spree::Order.find_by_number(id)
    end

end