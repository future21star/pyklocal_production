module Spree
  UserSessionsController.class_eval do 
    before_filter :configure_sign_in_params, only: [:create]

   def new
    super
   end

   def create
    @user = Spree::User.where(email: params[:spree_user][:email]).first
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    if !session[:return_to].blank?
     redirect_to session[:return_to]
     session[:return_to] = nil
    else
      if @user.has_store
        respond_with @user.stores.first.slug, :location => after_sign_in_path_for_merchant(@user.stores.first.slug)
      else
        respond_with resource, :location => after_sign_in_path_for(resource)
      end
     
    end
   end

   def destroy
    super
   end


   def configure_sign_in_params
    devise_parameter_sanitizer.for(:sign_in) << :attribute
   end

   private
   
    def after_sign_in_path_for_merchant(resource)
        return "/merchant/stores/#{resource}/orders"
    end
  
  end

end