class Merchant::ImagesController < Merchant::ApplicationController

	layout 'merchant'
	before_filter :find_image, only: [:destroy, :edit, :update]
	before_filter :load_product

	def index
		@images = @product.variant_images
	end

	def new
		@image = Spree::Image.new
		@variants = @product.variants.map do |variant|
      [variant.sku_and_options_text, variant.id]
    end
    @variants.insert(0, [Spree.t(:all), @product.master.id])
	end

	def edit
		@variants = @product.variants.map do |variant|
      [variant.sku_and_options_text, variant.id]
    end
    @variants.insert(0, [Spree.t(:all), @product.master.id])
	end

	def create
		unless params[:image][:attachment].blank?
			extension = params[:image][:attachment].original_filename.split('.').second.strip
			if ["jpeg","png","jpg"].include?(extension)
				@image = Spree::Image.new(image_params)
				if @image.save
					redirect_to merchant_product_images_path(@product), notice: "Image uploaded successfully"
				else
					render action: 'new'
				end
			else
				redirect_to :back, notice: "Image extension can be jpeg, jpg or png"
			end
		else
			redirect_to :back, notice: "No file selected"
		end
	end

	def update
		if @image.update_attributes(image_params)
			redirect_to merchant_product_images_path(@product), notice: "Images updated successfully"
		else
			render action: 'edit'
		end
	end

	def destroy
		if @image.destroy
			redirect_to  merchant_product_images_path(@product), notice: "Image Deleted successfully"
		else
			redirect_to  merchant_product_images_path(@product), notice: "Something went wrong"
		end
	end

	private

	  def image_params
	  	params.require(:image).permit(:attachment, :viewable_id, :alt, :viewable_type)
	  end

	  def find_image
	  	@image = Spree::Image.where(id: params[:id]).first
	  end

	  def load_product
	  	@product = Spree::Product.where(slug: params[:product_id]).first
	  end

end