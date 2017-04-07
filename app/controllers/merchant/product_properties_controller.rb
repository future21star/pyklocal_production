class Merchant::ProductPropertiesController < Merchant::ApplicationController

	before_filter :find_product_properties, only: [:edit, :update, :destroy]
	before_filter :load_product

	def index
		@properties = Spree::Property.pluck(:name)
		@product_properties = @product.product_properties
		@product_property = Spree::ProductProperty.new
	end

	def destroy
		p @product_property
		if @product_property.destroy_all
			redirect_to :back, notice: "Property deleted successfully"
		else
			redirect_to :back, notice: @product_property.errors.full_messages.join(', ')
		end
	end

	private
		def find_product_properties
			@product_property = Spree::ProductProperty.where(id: params[:id])
		end

		def load_product
			@product = Spree::Product.where(slug: params[:product_id]).first
		end

end