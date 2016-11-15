Spree::StoreController.class_eval do

  before_action :check_user

  def check_user
    unless (params[:controller] == "spree/users" || params[:controller] == "spree/orders") && (params[:action] == "edit" || params[:action] == "update" || params[:action] == "ready_to_pick")
      if current_spree_user && (current_spree_user.has_spree_role?("merchant") || current_spree_user.registration_type == "vendor")
        redirect_to main_app.merchant_stores_path, notice: 'You are not Authorized to perform this action'
      end
    end
  end

end
