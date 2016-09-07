module Spree
  RoleUser.class_eval do 

    after_create :send_notification_to_driver

    private

      def send_notification_to_driver
        if role.name == 'driver'
          UserMailer.notify_driver_approval(user).deliver_now
        end
      end
  end
end