module Spree
  UserRegistrationsController.class_eval do 

    def new
      @user = Spree::User.new
    end
    
    def create
      @user = build_resource(spree_user_params)
      resource_saved = resource.save
      yield resource if block_given?
      if resource_saved
        if resource.active_for_authentication?
          set_flash_message :notice, spree_user_params["stores_attributes"].present? ? :inactive_store : :signed_up
          sign_up(resource_name, resource)
          session[:spree_user_signup] = true
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_in!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        if spree_user_params["stores_attributes"].present?
          set_flash_message :error, :"#{resource.errors.full_messages.join(', ')}"
          redirect_to new_store_application_url
        else
          set_flash_message :error, :"#{resource.errors.full_messages.join(', ')}"
          render action: :new
        end
      end
    end

    private

      def spree_user_params
        params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes, :registration_type)
      end
  end
end