class Merchant::ProductsController < Merchant::ApplicationController

  # alias_method :old_stock, :stock
  before_filter :is_active_store
  before_filter :verify_access_for_merchants, only: [:new, :index, :stock]
  before_filter :find_product, only: [:edit, :update, :destroy, :images, :product_properties, :stock]

  layout 'merchant'

	def index
    @collection =  Spree::Product.where(store_id: current_spree_user.pyklocal_stores.first.id)
  end

  def new
    @product = Spree::Product.new
    @product.sku = SecureRandom.hex(10).upcase
    @shipping_categories = Spree::ShippingCategory.all
  end

  def edit
    @shipping_categories = Spree::ShippingCategory.all
    @tax_categories = Spree::TaxCategory.all
  end

  def create
    @product = Spree::Product.new(product_params)
    @product.attributes = product_params.merge({store_id: current_spree_user.pyklocal_stores.first.id})
    if @product.save
      redirect_to merchant_products_path, notice: "Product added successfully"
    else
      render action: 'new'
    end
  end

  def update
    if @product.update_attributes(product_params)
      redirect_to merchant_products_path, notice: "Product updated successfully"
    else
      render action: 'edit'
    end
  end

  def destroy
    if @product.destroy
      redirect_to merchant_products_path, notice: "Product deleted successfully"
    else
      redirect_to merchant_products_path, notice: "Something went wrong"
    end
  end

  def images
    @image = Spree::Image.new
    @images = Spree::Image.where(viewable_id: @product.id)
  end

  def product_properties
    @product_property = Spree::ProductProperty.new
    @product_properties = @product.product_properties
  end

  def stock
    @stock = Spree::StockItem.new
    @stock_locations = Spree::StockLocation.all
    @variants = @product.variants
    if !@current_spree_user.has_spree_role?('admin')
      if @product.store_id != @current_spree_user.stores.first.try(:id)
        raise CanCan::AccessDenied.new
      end
    end
    # old_stock
  end

  private

  def product_params
    params.require(:product).permit(:name, :slug, :description, :taxon_ids, :option_type_ids, :tax_category_id, :buyer_protection, :include_paypal, :price, :condition, :sku, :store_id, :shipping_category_id, :shipping_duration, :international_shipping_cost, :buyer_protection_desc, :available_on, :end_date, :payment_method, :prototype_id)
  end

  def verify_access_for_merchants
    unless @current_spree_user.has_spree_role?('admin') || @current_spree_user.has_spree_role?('merchant')
      raise CanCan::AccessDenied.new
    end
  end

  def find_product
    @product = Spree::Product.where(slug: params[:id]).first || Spree::Product.where(slug: params[:product_id]).first
  end

end
