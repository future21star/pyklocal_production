Devise::ConfirmationsController.class_eval  do

	def show
    @user = Spree::User.find_by_confirmation_token(params[:confirmation_token])
    if @user.confirmed_at.blank?
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        set_flash_message(:notice, :confirmed) if is_flashing_format?
        respond_with_navigational(resource){ redirect_to after_confirmation_path_for(resource_name, resource) }
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
      end
    else
      redirect_to root_path,notice: "Account is already Confirmed"
    end
  end
	
end