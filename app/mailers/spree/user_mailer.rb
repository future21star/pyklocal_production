module Spree
  class UserMailer < BaseMailer
    default from: 'sales@pyklocal.com'

    def notify_driver_approval(user)
      @user = user
      mail(to: user.email, from: from_address, subject: "#{@user.full_name} is now approved as a driver")
    end

    def reset_password_instructions(user, token, *args)
      @edit_password_reset_url = spree.edit_spree_user_password_url(:reset_password_token => token, :host => Rails.application.secrets.HOST_URL)

      mail to: user.email, from: from_address, subject: Spree::Store.current.name + ' ' + I18n.t(:subject, :scope => [:devise, :mailer, :reset_password_instructions])
    end

    def confirmation_instructions(user, token, opts={})
      @confirmation_url = spree.spree_user_confirmation_url(:confirmation_token => token, :host => Rails.application.secrets.HOST_URL)
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

    def notify_small_amount_of_product(variant)
      @variant = variant
      @product = variant.product
      @seller = @product.store.try(:spree_users).try(:first)
      if @seller
        mail(to: @seller.email, subject: "Product stock is less than 5")
      end
    end

    def notify_user_store_destroy(user)
      @user = user
      mail(to: @user.email, subject: "Store Remove Notification")
    end

    def notify_items_out_for_delivery(line_items)
      @user = line_items.first.order.user
      @line_items = line_items
      mail(to: @user.email, from: "sales@pyklocal.com",subject: "Out For Delivery")
    end

    def notify_return_order_item(return_item)
      @user = return_item.order.user
      @return_item = return_item
      mail(to: @user.email, subject: "Return Item")
      mail(to: "manish.rai@w3villa.com", subject: "Return Item")
    end

    def notify_order_items_delivered(order)
      p "7888888888777"
      @order = order
      @user = order.user
      mail(to: @user.email ,from: "sales@pyklocal.com", subject: "PykLocal Order Delivered Confirmation")
    end
  end
end