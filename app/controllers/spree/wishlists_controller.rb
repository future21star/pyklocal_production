class Spree::WishlistsController < Spree::StoreController

  before_action :authenticate_spree_user!

  def index
    @wishlists = current_spree_user.try(:wishlists)
  end

  def create
    @wishlist = Spree::Wishlist.new wishlist_params
    @wishlist.user = current_spree_user
    @wishlist.save
    redirect_to :back, notice: "Product added into your wishlist"
  end

  def destroy
    Spree::Wishlist.where(id: params[:id]).first.try(:destroy)
    redirect_to wishlists_url, notice: "Item removed from wishlist"
  end

  private

    def wishlist_params
      params.require(:wishlist).permit(:variant_id, :user_id)
    end

end