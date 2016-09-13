module Spree
  class UserMailer < BaseMailer  
    def notify_driver_approval(user)
      @user = user
      mail(to: user.email, subject: "#{@user.full_name} is now approved as a driver")
    end
  end
end