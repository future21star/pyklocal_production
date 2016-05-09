class Merchant::ImagesController < Merchant::ApplicationController

	layout 'merchant'
	before_filter :find_image, only: [:destroy]

	def index
		@product = Spree::Product.where(slug: params[:product_id]).first
		@images = @product.images
	end

	def new
		@image = Spree::Image.new
		@product = Spree::Product.where(slug: params[:product_id]).first
	end

	def create
		@image = Spree::Image.new(image_params)
		if @image.save
			redirect_to :back, notice: "Image uploaded successfully"
		else
			redirect_to :back, notice: @image.errors.full_messages.join(", ")
		end
	end

	def destroy
		if @image.destroy
			redirect_to :back, notice: "Deleted successfully"
		else
			redirect_to :back, notice: "Something went wrong"
		end
	end

	private

	  def image_params
	  	params.require(:image).permit(:attachment, :viewable_id, :alt, :viewable_type)
	  end

	  def find_image
	  	@image = Spree::Image.where(id: params[:id]).first
	  end

end