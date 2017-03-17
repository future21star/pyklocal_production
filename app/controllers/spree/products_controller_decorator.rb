module Spree
  ProductsController.class_eval do 
    impressionist actions: [:show]

    def show
      @variants = @product.variants_including_master.
                           spree_base_scopes.
                           active(current_currency).
                           includes([:option_values, :images])
      @product_properties = @product.product_properties.includes(:property)
      @product.increment_counter
      @taxon = params[:taxon_id].present? ? Spree::Taxon.find(params[:taxon_id]) : @product.taxons.first
      impressionist(@product, "Products count increase by 1")
      redirect_if_legacy_path
    end

    private
      def load_product

        if try_spree_current_user.try(:has_spree_role?, "admin")
          @products = Product.with_deleted
        else
          @products = Product.active(current_currency)
        end
        @product = Spree::Product.friendly.find(params[:id])
        if @product.visible
          @product = @products.includes(:variants_including_master).friendly.find(params[:id])
        else
          redirect_to spree.root_path, notice: "Product is no longer available"
        end
      end

  end
end