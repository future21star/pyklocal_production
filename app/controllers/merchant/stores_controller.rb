class Merchant::StoresController < Merchant::ApplicationController

	before_filter :authenticate_user!, except: [:show, :new, :create, :index,:edit,:update]
  before_action :set_store, only: [:show, :edit, :update, :destroy]
  # before_action :validate_token, only: [:edit, :update] 
  before_action :perform_search, only: [:show]

	def index
		@stores = current_spree_user.try(:stores)
    if @stores.present?
      redirect_to @stores.first
    else
      redirect_to new_merchant_store_path
    end     
	end

	def show
    #@products = @store.spree_products.page(params[:page]).per(12).order("created_at desc")
    @products = @search.results
    @is_owner = is_owner?(@store)
  end

  # GET /stores/new
  def new
    if current_spree_user && current_spree_user.stores.present?
      redirect_to current_spree_user.stores.first
    elsif current_spree_user.registration_type == "vendor"
      @store = Merchant::Store.new
      p "88888888888"
     # @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
     @taxons = Spree::Taxon.where(parent_id: nil)
    # elsif current_spree_user.registration_type == "customer"
    #   redirect_to spree.root_path
    # elsif current_spree_user.registration_type == nil
    #   redirect_to spree.root_path
    else 
      redirect_to merchant_stores_path
    end
  end

  # GET /stores/1/edit
  def edit
    p "edit called"
    if current_spree_user.present?
      if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
        raise CanCan::AccessDenied.new
      end
      # @taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
      @taxons = Spree::Taxon.where(parent_id: nil)
    else
      redirect_to spree.root_path, notice: "You are not logged in"
    end
  end

  # POST /stores
  # POST /stores.json
  def create
    @store = Merchant::Store.new(store_params)
    @store.attributes = {store_users_attributes: [spree_user_id: current_spree_user.id], active: true}
    respond_to do |format|
      if @store.save
        format.html { redirect_to merchant_store_url(id: @store.slug, anchor: "map"), notice: 'Store approval is pending' }
        format.json { render action: 'show', status: :created, location: @store }
      else
        #@taxons = Spree::Taxon.where(depth: 1, parent_id: Spree::Taxon.where(name: "Categories").first.id)
        @taxons = Spree::Taxon.where(parent_id: nil).first.id
        format.html { render action: 'new' }
        format.json { render json: @store.errors, status: :unprocessable_entity }
        flash[:error] = @store.errors.full_messages.join(", ")
      end
    end
  end

  # PATCH/PUT /stores/1
  # PATCH/PUT /stores/1.json
  def update
    if current_spree_user.present?
      if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
        raise CanCan::AccessDenied.new
      end
    else
      redirect_to spree.root_path, notice: "You are not logged in"
    end
    respond_to do |format|
      if params[:merchant_store][:spree_taxon_ids].present?
        params[:merchant_store][:spree_taxon_ids].each do |parent_taxon|
          children_taxons = Spree::Taxon.where(parent_id: parent_taxon).collect{|taxon| taxon.id.to_s}
          if children_taxons.present?
            children_taxons.each do |taxon|
              params[:merchant_store][:spree_taxon_ids].push(taxon)
            end
          end
        end
      end
      if @store.update_attributes(store_params)
        format.html { redirect_to @store, notice: 'Store was successfully updated.'  }
        # @store.email_tokens.last.update_attributes(is_valid: false)
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /stores/1
  # DELETE /stores/1.json
  def destroy
    if @store.id != current_spree_user.stores.first.try(:id) && !current_spree_user.has_spree_role?('admin')
      raise CanCan::AccessDenied.new
    end
    @store.destroy
    respond_to do |format|
      if current_spree_user.has_spree_role?('admin')
        format.html { redirect_to merchant_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      else
        format.html { redirect_to merchant_stores_url, notice: 'Store was deleted successfully.' }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_store
      p params[:id]
      @store = Merchant::Store.where(slug: params[:id]).first
      redirect_to spree.root_url, notice: "Store not available" unless @store.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def store_params
      params.require(:merchant_store).permit(:name, :estimated_delivery_time, :active, :certificate, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], store_users_attributes: [:spree_user_id, :store_id, :id])
    end

    def remove_subtaxon(taxons,store)
      p "--------------"
      taxons.each do |taxon|
        @taxon_children = Spree::Taxon.find(taxon.to_i).children
        if @taxon_children.present?
          # Merchant::StoreTaxon.where(store_id: store.id, taxon_id: @taxon_children.map(&:id)).destroy_all
          @taxon_children.each do |taxon_child|
            p "removed"
            @taxon =  Merchant::StoreTaxon.where(store_id: store.id, taxon_id: taxon_child.id)
            if @taxon.present?
              @taxon.destroy
            end
          end
        end
      end
    end

    def perform_search
        #per_page = params[:q] && params[:q][:per_page] ? params[:q][:per_page] : 12
      store_id = Merchant::Store.where(slug: params[:id]).first.id
      @search = Sunspot.search(Spree::Product) do 
        fulltext "*#{params[:q][:search]}*" if params[:q] && params[:q][:search]
        paginate(:page => params[:page], :per_page => 12)
        with(:store_id, store_id) 
        with(:visible, true) if !current_spree_user.present? || !current_spree_user.has_store || current_spree_user.stores.first.id != store_id
        with(:buyable, :true)
      end
    end

    def validate_token
      @store = Merchant::Store.find_by_slug(params[:id])
      if @store.email_tokens.where(is_valid: true, token: params[:token]).blank?
        redirect_to merchant_store_url(@store), flash: {error: "Please use the link provided in mail to edit the store, token was invalid"}
      end
    end

end
