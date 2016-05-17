class Merchant::PyklocalStoresController < Merchant::ApplicationController

	before_filter :authenticate_spree_user!, except: [:show]
  before_action :set_store, only: [:show, :edit, :update, :destroy]
  before_filter :validate_token, only: [:edit, :update] 
	def index
		@stores = current_spree_user.try(:pyklocal_stores)
    if @stores.present?
      redirect_to merchant_stores_path(id: @stores.first.id)
    else
      redirect_to new_merchant_store_path
    end
        
	end

	def show
    if @store.present?
      if !current_spree_user.nil? || current_spree_user.pyklocal_stores.collect(&:id).include?(@store.id) || current_spree_user.has_spree_role?('merchant') || current_spree_user.has_spree_role?('admin')
        @products = @store.spree_products
      end
    else
      redirect_to new_merchant_pyklocal_store_path
    end
  end

  # GET /stores/new
  def new
    @store = PyklocalStore.new()
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

  # GET /stores/1/edit
  def edit
    if @store.id != current_spree_user.pyklocal_stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = PyklocalStore.new(store_params)
    @store.attributes = {pyklocal_store_users_attributes: [spree_user_id: current_spree_user.id], active: true}
    respond_to do |format|
      if @store.save
        format.html { redirect_to [:merchant, @store], notice: 'Store pending approval' }
        format.json { render action: 'show', status: :created, location: @store }
      else
        @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
        p "=============================================================================="
        p @store.errors
        format.html { render action: 'new' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    if @store.id != current_spree_user.pyklocal_stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    respond_to do |format|
      if @store.update_attributes(store_params)
        format.html { redirect_to [:merchant, @store], notice: 'Store was successfully updated.'  }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    if @store.id != current_spree_user.pyklocal_stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    @store.destroy
    respond_to do |format|
      if current_spree_user.has_spree_role?('admin')
        format.html { redirect_to merchant_pyklocal_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to merchant_pyklocal_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      @store = PyklocalStore.where(id: params[:id]).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:pyklocal_store).permit(:name, :active, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], pyklocal_store_users_attributes: [:spree_user_id, :store_id, :id])
    end

    def validate_token
      if (@store.email_tokens.where(is_valid: true, token: params[:token]).blank? && current_spree_user.has_spree_role?("merchant") && !current_spree_user.has_spree_role?("admin"))
        redirect_to merchant_store_url(@store), flash: {error: "Please use the link provided in mail to edit the store, token was invalid"}
      end
    end

end