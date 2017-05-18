class Spree::Admin::InfoCommercialsController < Spree::Admin::ResourceController

	before_filter :find_info_commercial, only: [:edit, :update, :destroy]

  def index
    @info_commercials = Spree::InfoCommercial.all
  end

  def new
    @info_commercial = Spree::InfoCommercial.new
  end

  def edit
    
  end

  def create
    @info_commercial = Spree::InfoCommercial.new(info_commercial_params)
    if @info_commercial.save
      redirect_to admin_info_commercials_path, notice: "Video is saved successfully"
    else
      render action: 'new'
    end
  end

  def update
    if @info_commercial.update_attributes(info_commercial_params)
      redirect_to admin_info_commercials_path, notice: "Updated successfully"
    else
      render action: 'edit'
    end
  end

  def destroy
    if @info_commercial.destroy
      redirect_to admin_info_commercials_path, notice: "Deleted successfully"
    else
      redirect_to admin_info_commercials_path, notice: "Something went wrong"
    end
  end

  private

    def info_commercial_params
      params.require(:info_commercial).permit(:video, :active)
    end

    def find_info_commercial
      @info_commercial = Spree::InfoCommercial.where(id: params[:id]).first
      redirect_to admin_info_commercials_path, notice: "No image found with this reference" if @info_commercial.blank?
    end
end
