class Spree::WishlistsController < Spree::StoreController

  before_action :authenticate_spree_user!

  def index
    @wishlists = current_spree_user.try(:wishlists)
  end

  def create
    unless current_spree_user.wishlists.collect(&:variant_id).include?(params[:wishlist][:variant_id].to_i)
      @wishlist = Spree::Wishlist.new wishlist_params
      @wishlist.user = current_spree_user
      @wishlist.save
      redirect_to :back, notice: "Product added into your wishlist"
    else
       redirect_to :back, notice: "Product already present in wishlist"
    end
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