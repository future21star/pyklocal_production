class Merchant::OrdersController < Merchant::ApplicationController

	before_filter :is_active_store
  before_filter :find_order, only: [:edit, :update, :validate_actions, :customer, :adjustments, :payments, :returns, :approve, :cancel]
	layout 'merchant'

	def index
    params[:q] ||= {}
    params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
    @show_only_completed = params[:q][:completed_at_not_null] == '1'
    params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'

    # As date params are deleted if @show_only_completed, store
    # the original date so we can restore them into the params
    # after the search
    created_at_gt = params[:q][:created_at_gt]
    created_at_lt = params[:q][:created_at_lt]

    params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

    if !params[:q][:created_at_gt].blank?
      params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
    end

    if !params[:q][:created_at_lt].blank?
      params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
    end

    if @show_only_completed
      params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
      params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
    end

    if @current_spree_user.has_spree_role?('merchant')
    	@orders = Spree::Order.joins({line_items: {variant: :product}}).where("spree_products.store_id = ?", @current_spree_user.stores.first.try(:id))
    else 
    	@orders = Order.accessible_by(current_ability, :index)
    end	

    @search = @orders.ransack(params[:q])

    # lazyoading other models here (via includes) may result in an invalid query
    # e.g. SELECT  DISTINCT DISTINCT "spree_orders".id, "spree_orders"."created_at" AS alias_0 FROM "spree_orders"
    # see https://github.com/spree/spree/pull/3919
    @orders = @search.result(distinct: true).page(params[:page]).per(params[:per_page] || Spree::Config[:orders_per_page])
    # Restore dates

    params[:q][:created_at_gt] = created_at_gt
    params[:q][:created_at_lt] = created_at_lt
  end

  def new
  	if !@current_spree_user.has_spree_role?('admin')
      if @current_spree_user.has_spree_role?('merchant')
        raise CanCan::AccessDenied.new
      end
    end  
    @order = Order.create
    @order.created_by = try_spree_current_user
    @order.save
    redirect_to edit_admin_order_url(@order)
  end

  def edit
  	validate_actions
    unless @order.complete?
      @order.refresh_shipment_rates
    end
  end

  def update
  	validate_actions
    if @order.update_attributes(params[:order]) && @order.line_items.present?
      @order.update!
      unless @order.complete?
        # Jump to next step if order is not complete.
        redirect_to admin_order_customer_path(@order) and return
      end
    else
      @order.errors.add(:line_items, Spree.t('errors.messages.blank')) if @order.line_items.empty?
    end

    render :action => :edit
  end

  def cancel
  	validate_actions
    @order.cancel!
    flash[:success] = Spree.t(:order_canceled)
    redirect_to :back
  end

  def customer
    @customer = @order.user
    @bill_address = @customer.try(:bill_address)
  end

  def adjustments
    @adjustments = @order.adjustments
  end

  def payments
    @payments = @order.payments
  end

  def returns
    
  end

  def approve
    if @order.update_attributes(approver_id: current_spree_user.id, approved_at: Time.zone.now, considered_risky: false)
      redirect_to :back, notice: "Order Approved"
    else
      redirect_to :back, notice: @order.errors.full_messages.join(", ")
    end
  end

  def cancel
    validate_actions
    @order.cancel!
    flash[:success] = Spree.t(:order_canceled)
    redirect_to :back
  end

  private 

  	def validate_actions
  		rais_error = true
    	if !@current_spree_user.has_spree_role?('admin')
        if @current_spree_user.has_spree_role?('merchant')
        		@order.line_items.each do |line_item|
        			if line_item.variant.product.store_id == @current_spree_user.stores.first.id
        				rais_error = false
        				break
        			end	
        		end
        	if rais_error
          	raise CanCan::AccessDenied.new
          end	
        end
      end  
  	end

    def find_order
      @order = Spree::Order.where(number: params[:id]).first || Spree::Order.where(number: params[:order_id]).first
    end	

end