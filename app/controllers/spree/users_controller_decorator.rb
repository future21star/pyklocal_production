Spree::UsersController.class_eval do

  def update
    # if @user.email == params[:user][:email]
      if @user.update_attributes(user_params)
        if params[:user][:password].present?
          # this logic needed b/c devise wants to log us out after password changes
          user = Spree::User.reset_password_by_token(params[:user])
          sign_in(@user, :event => :authentication, :bypass => true)
          redirect_to change_password_account_path, :notice => Spree.t(:account_updated_successfully)
        else
          redirect_to edit_account_path, :notice => Spree.t(:account_updated_successfully)
        end
      else
        if params[:user][:password].present?
          render :change_password
        else
          render :edit
        end
      end
    # else
      # redirect_to edit_account_path, :notice => "Please Provide Valid Email"
    # end
  end

  def change_password
    @user = spree_current_user
  end

end

