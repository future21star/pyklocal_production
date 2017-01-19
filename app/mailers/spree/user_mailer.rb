module Spree
  class UserMailer < BaseMailer
    def notify_driver_approval(user)
      @user = user
      mail(to: user.email, from: from_address, subject: "#{@user.full_name} is now approved as a driver")
    end

    def reset_password_instructions(user, token, *args)
      @edit_password_reset_url = spree.edit_spree_user_password_url(:reset_password_token => token, :host => Spree::Store.current.url)

      mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :reset_password_instructions])
    end

    def confirmation_instructions(user, token, opts={})
      @confirmation_url = spree.spree_user_confirmation_url(:confirmation_token => token, :host => Spree::Store.current.url)
      mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :confirmation_instructions])
    end

    def notify_out_of_stock_product(variant)
      @variant = variant
      @product = variant.product
      @seller = @product.store.try(:spree_users).try(:first)
      if @seller
        mail(to: @seller.email, subject: "Product Out Of Stock")
      end
    end

    def notify_user_store_destroy(user)
      @user = user
      mail(to: @user.email, subject: "Store Remove Notification")
    end

    def notify_items_out_for_delivery(line_items)
      @user = line_items.first.order.user
      @line_items = line_items
      mail(to: @user.email, subject: "Out For Delivery")
    end

    def notify_order_items_delivered(order)
      @order = order
      @user = order.user
      mail(to: @user.email , subject: "PykLocal Order Delivered Confirmation")
    end
  end
end