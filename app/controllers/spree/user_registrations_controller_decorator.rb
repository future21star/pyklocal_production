module Spree
  UserRegistrationsController.class_eval do 
    
    def create
      @user = build_resource(spree_user_params)
      resource_saved = resource.save
      yield resource if block_given?
      if resource_saved
        if resource.active_for_authentication?
          p "************************************************************"
          p spree_user_params["stores_attributes"].present?
          set_flash_message :notice, spree_user_params["stores_attributes"].present? ? Spree.t(:"PYKLOCAL_is_currently_reviewing_the_registration_request_and_will_approve_in_next_24-48_hours") : :signed_up
          sign_up(resource_name, resource)
          session[:spree_user_signup] = true
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords(resource)
        render :new
      end
    end

    private

      def spree_user_params
        params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes)
      end
  end
end