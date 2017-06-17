class Spree::WishlistsController < Spree::StoreController

  before_action :authenticate_spree_user!

  def index
    @wishlists = current_spree_user.try(:wishlists)
    # if @wishlists.present?
    #   @wishlists = @wishlists.select{|wishlist| wishlist.variant.product.visible == true && wishlist.variant.product.buyable == true}
    # end
  end

  def create
    if Spree::Product.find(params[:wishlist][:product_id]).total_on_hand > 0
      unless current_spree_user.wishlists.collect(&:product_id).include?(params[:wishlist][:product_id].to_i)
        @wishlist = Spree::Wishlist.new wishlist_params
        @wishlist.user = current_spree_user
        @wishlist.save
        redirect_to :back, notice: "Product added into your wishlist"
      else
         redirect_to :back, notice: "Product already present in wishlist"
      end
    else
      redirect_to :back, notice: "Out Of Stock Product can not be added to wishlist"
    end
  end

  def destroy
    Spree::Wishlist.where(id: params[:id]).first.try(:destroy)
    redirect_to wishlists_url, notice: "Item removed from wishlist"
  end

  private

    def wishlist_params
      params.require(:wishlist).permit(:product_id, :user_id)
    end

end