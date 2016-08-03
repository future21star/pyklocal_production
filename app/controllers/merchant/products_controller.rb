class Merchant::ProductsController < Merchant::ApplicationController

  # alias_method :old_stock, :stock
  before_filter :is_active_store
  before_filter :verify_access_for_merchants, only: [:new, :index, :stock]
  before_filter :find_product, only: [:edit, :update, :destroy, :images, :product_properties, :stock]

  layout 'merchant'

	def index
    @collection =  Spree::Product.where(store_id: current_spree_user.stores.first.id).order("created_at desc").page(params[:page]).per(15)
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def new
    @product = Spree::Product.new
    @product.sku = SecureRandom.hex(10).upcase
    @shipping_categories = Spree::ShippingCategory.all
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def edit
    @shipping_categories = Spree::ShippingCategory.all
    @tax_categories = Spree::TaxCategory.all
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def create
    @is_owner = is_owner?(current_spree_user.stores.first)
    @product = Spree::Product.new(product_params)
    @product.attributes = product_params.merge({store_id: current_spree_user.stores.first.id})
    if @product.save
      redirect_to edit_merchant_product_path(@product), notice: "Product added successfully"
    else
      @product.sku = SecureRandom.hex(10).upcase
      @shipping_categories = Spree::ShippingCategory.all
      render action: 'new'
    end
  end

  def bulk_upload
    row_array = Array.new
    my_file = params[:file]
    ImportProductWorker.perform_in(5.seconds, my_file.path, current_spree_user.email)
    redirect_to merchant_products_path, notice: "Your Product importing from the csv you uploaded, we will notify you it's progress through email"
  end

  def sample_csv
    send_file(File.open(Rails.root.join("public", "sample_csv.csv"), "r"))
  end

  def update
    redirect_path = params[:redirect_path].present? ? params[:redirect_path] : edit_merchant_product_path(@product)
    if @product.update_attributes(product_params)
      redirect_to redirect_path, notice: "Product updated successfully"
    else
      @shipping_categories = Spree::ShippingCategory.all
      @tax_categories = Spree::TaxCategory.all
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
    @is_owner = is_owner?(current_spree_user.stores.first)
  end

  def stock
    @is_owner = is_owner?(current_spree_user.stores.first)
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
    params.require(:product).permit(:name, :slug, :description,:asin,:brand, :taxon_ids, :option_type_ids, :tax_category_id, :price, :sku, :store_id, :shipping_category_id, :available_on, :discontinue_on, :promotionable, :payment_method, :cost_price, :cost_currency, :weight, :height, :width, :depth, :meta_keywords, :meta_description, product_properties_attributes: [:property_id, :value, :id, :property_name])
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
