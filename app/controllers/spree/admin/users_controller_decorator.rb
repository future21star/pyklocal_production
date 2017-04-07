module Spree
	module Admin
		UsersController.class_eval  do


			def create
        @user = Spree.user_class.new(user_params.merge({t_and_c_accepted: true}))
        if @user.save
          flash.now[:success] = flash_message_for(@user, :successfully_created)
          render :edit
        else
          render :new
        end
      end


		end
	end
end