module Spree
  class Api::V1::UsersFeedbacksController < Spree::Api::BaseController

    before_filter :find_user, only: [:create, :index]

    def create
      unless
      else
      end
    end

    private

    def find_user
      @user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
    end


    def user_feedback_params
      params.require(:user_feedback).permit(:user_id, :name, :comment, :value, :emails)
    end

  end
end