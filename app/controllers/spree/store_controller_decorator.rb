Spree::StoreController.class_eval do

  before_action :check_user

  def check_user
    unless params[:controller] == "spree/users" && (params[:action] == "edit" || params[:action] == "update")
      if current_spree_user && (current_spree_user.has_spree_role?("merchant") && current_spree_user.registration_type == "vendor")
        redirect_to main_app.merchant_stores_path
      end
    end
  end

end
