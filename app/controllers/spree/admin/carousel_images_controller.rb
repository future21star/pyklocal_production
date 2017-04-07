class Spree::Admin::CarouselImagesController < Spree::Admin::ResourceController

  before_filter :find_carousel_image, only: [:edit, :update, :destroy]

  def index
    @carousel_images = Spree::CarouselImage.all
  end

  def new
    @carousel_image = Spree::CarouselImage.new
  end

  def edit
    
  end

  def create
    @carousel_image = Spree::CarouselImage.new(carousel_image_params)
    if @carousel_image.save
      redirect_to admin_carousel_images_path, notice: "Images saved successfully"
    else
      render action: 'new'
    end
  end

  def update
    if @carousel_image.update_attributes(carousel_image_params)
      redirect_to admin_carousel_images_path, notice: "Updated successfully"
    else
      render action: 'edit'
    end
  end

  def destroy
    if @carousel_image.destroy
      redirect_to admin_carousel_images_path, notice: "Deleted successfully"
    else
      redirect_to admin_carousel_images_path, notice: "Something went wrong"
    end
  end

  private

    def carousel_image_params
      params.require(:carousel_image).permit(:image, :active, :resource_id, :resource_type)
    end

    def find_carousel_image
      @carousel_image = Spree::CarouselImage.where(id: params[:id]).first
      redirect_to admin_carousel_images_path, notice: "No image found with this reference" if @carousel_image.blank?
    end

end