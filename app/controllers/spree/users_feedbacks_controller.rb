class Spree::UsersFeedbacksController < Spree::StoreController


    def create
      p "999999999999999999999999999999999"
      p params
      @user_feedback = Feedback.new(user_feedback_params)
      if @user_feedback.save
        redirect_to root_path, notice: "Thank you for sharing your experience with"
      else
        require :back
      end
    end

    private

    def find_user
      @user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
    end


    def user_feedback_params
      params.require(:feedback).permit(:user_id, :name, :comment, :value, :email)
    end
end