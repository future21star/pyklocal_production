module Spree
  UserRegistrationsController.class_eval do

    def new
      p "kkkjdksdjksdjksdjkd"
      @tab = params[:active_tab]
      @user = Spree::User.new
    end
    
    def create
      unless Spree::User.with_deleted.find_by_email(params[:spree_user][:email]).present?
        @tab = params[:tab]
        @user = build_resource(spree_user_params)
        resource_saved = resource.save
        yield resource if block_given?
        if resource_saved
          if resource.active_for_authentication?
            set_flash_message :notice, spree_user_params["stores_attributes"].present? ? :inactive_store : :signed_up
            sign_up(resource_name, resource)
            session[:spree_user_signup] = true
            if @user.has_store
              respond_with @user.stores.first.slug, :location => after_sign_up_path_for_merchant(@user.stores.first.slug)
            elsif @user.registration_type == "vendor"
              respond_with @user , :location => after_sign_up_path
            else
              respond_with resource, location: after_sign_up_path_for(resource)
            end
          else
            set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
            expire_data_after_sign_in!
            respond_with resource, location: after_inactive_sign_up_path_for(resource)
          end
        else
          if spree_user_params["stores_attributes"].present?
            flash[:error] = resource.errors.full_messages.join(", ")
            redirect_to new_store_application_url
          else
            flash.now[:error] = resource.errors.full_messages.join(", ")
            render action: :new
          end
        end
      else
        redirect_to :back, notice: "Email is already registered"
      end
    end

    private

      def spree_user_params
        params.require(:spree_user).permit(Spree::PermittedAttributes.user_attributes, :registration_type,:first_name, :last_name)
      end
   
      def after_sign_up_path_for_merchant(resource)
          return "/merchant/stores/#{resource}"
      end

      def after_sign_up_path
        return "/merchant/stores/new"
      end
  end
end