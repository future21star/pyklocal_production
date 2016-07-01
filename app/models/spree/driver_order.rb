module Spree
  class DriverOrder < ActiveRecord::Base

    self.table_name = "drivers_orders"

    belongs_to :driver, foreign_key: :driver_id, class_name: "Spree::User"
    belongs_to :cart_order, foreign_key: :order_id, class_name: "Spree::Order"

    after_update :notify_seller_and_user

    def store_name
      Spree::LineItem.where(id: line_item_ids.split(", ")).first.try(:product).try(:store_name)
    end

    def notify_seller_and_user
      if is_delivered
        stores = []
        UserMailer.delivery_notification_user(cart_order.try(:user), cart_order)
        cart_order.line_items.where(id: line_item_ids.join(", ")).each do |item|
          stores << item.product.store
        end
        stores.uniq.each do |store|
          UserMailer.delivery_notification_store(store, cart_order)
        end
      end
    end

  end
end