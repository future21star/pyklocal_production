class Merchant::ProductPropertiesController < Merchant::ApplicationController

	before_filter :find_product_properties, only: [:edit, :update, :destroy]
	before_filter :load_product

	def index
		@properties = Spree::Property.pluck(:name)
		@product_properties = @product.product_properties
		@product_property = Spree::ProductProperty.new
	end

	def new
		@product_property = Spree::ProductProperty.new
	end

	def edit
		
	end

	def create
		@product_property = Spree::ProductProperty.new(product_property_params)
		if @product_property.save
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Product property created successfully"
		else
			p "=============================================================="
			p @product_property.errors
			render action: 'index'
		end
	end

	def update
		if @product_property.update_attributes(product_property_params)
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Product property updated successfully"
		else
			render action: 'edit'
		end
	end

	def destroy
		if @product_property.destroy
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Deleted successfully"
		else
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Something went wrong"
		end
	end

	private
		def product_property_params
			params.require(:product_property).permit(:value, :product_id, :property_id, :position)
		end

		def find_product_properties
			@product_property = Spree::ProductProperty.where(id: params[:id])
		end

		def load_product
			@product = Spree::Product.where(slug: params[:product_id]).first
		end

end