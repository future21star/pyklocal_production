class Spree::Admin::StaticImagesController < Spree::Admin::ResourceController

  before_filter :find_static_image, only: [:edit, :update, :destroy]

  def index
    @static_images = Spree::StaticImage.where(is_static: true)
  end

  def new
    @static_image = Spree::StaticImage.new
  end

  def edit
    
  end

  def create
    @static_image = Spree::StaticImage.new(static_image_params.merge(is_static: true))
    if @static_image.save
      redirect_to admin_static_images_path, notice: "Images saved successfully"
    else
      render action: 'new'
    end
  end

  def update
    if @static_image.update_attributes(static_image_params)
      redirect_to admin_static_images_path, notice: "Updated successfully"
    else
      render action: 'edit'
    end
  end

  def destroy
    if @static_image.destroy
      redirect_to admin_static_images_path, notice: "Deleted successfully"
    else
      redirect_to admin_static_images_path, notice: "Something went wrong"
    end
  end

  private

    def static_image_params
      params.require(:static_image).permit(:image, :active, :is_static, :story, :position, :url)
    end

    def find_static_image
      @static_image = Spree::StaticImage.where(id: params[:id]).first
      redirect_to admin_static_images_path, notice: "No image found with this reference" if @static_image.blank?
    end

end