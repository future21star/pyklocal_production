module Spree
	Api::V1::UsersController.class_eval do
		skip_before_filter :authenticate_user

		def create
      @user = Spree.user_class.new(user_params)
      if @user.save
        respond_with(@user, :status => 201, :default_template => :show)
      else
        invalid_resource!(@user)
      end
    end

	end
end