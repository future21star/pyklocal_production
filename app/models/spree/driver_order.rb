module Spree
  class DriverOrder < ActiveRecord::Base

    belongs_to :driver, foreign_key: :driver_id, class_name: "Spree::User"
    belongs_to :cart_order, foreign_key: :order_id, class_name: "Spree::Order"

    self.table_name = "drivers_orders"

    def store_name
      Spree::LineItem.where(id: line_item_ids.split(", ")).first.try(:product).try(:store_name)
    end

  end
end