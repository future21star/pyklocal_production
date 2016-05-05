class Merchant::ProductPropertiesController < Merchant::ApplicationController

	before_filter :find_product_properties, only: [:edit, :update, :destroy]

	def index
		@product = Spree::Product.where(slug: params[:product_id]).first
		@product_properties = @product.product_properties
	end

	def new
		@product = Spree::Product.where(slug: params[:product_id]).first
		@product_property = Spree::ProductProperty.new
	end

	def edit
		@product = Spree::Product.where(slug: params[:product_id]).first
	end

	def create
		@product_property = Spree::ProductProperty.new(product_property_params)
		if @product_property.save
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Product property created successfully"
		else
			redirect_to :back, notice: @product_property.errors.full_messages.join(", ")
		end
	end

	def update
		if @product_property.update_attributes(product_property_params)
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: "Product property updated successfully"
		else
			redirect_to merchant_product_product_properties_path(product_id: @product_property.product.slug), notice: @product_property.errors.full_messages.join(", ")
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

end