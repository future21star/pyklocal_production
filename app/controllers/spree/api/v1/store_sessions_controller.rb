class Spree::Api::V1::StoreSessionsController < Spree::Api::BaseController

  skip_before_filter :authenticate_user

  def create
    session[:lat] = params[:lat]
    session[:lng] = params[:lng]
    render json: {success: true}
  end

end