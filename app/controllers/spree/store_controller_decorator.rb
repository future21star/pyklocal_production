Spree::StoreController.class_eval do

  before_action :check_user

  def check_user
    if current_spree_user && (current_spree_user.has_spree_role?("merchant") || current_spree_user.registration_type == "vendor")
      redirect_to main_app.merchant_stores_path, notice: "You are not a user, need to signup with user role."
    end
  end

end
