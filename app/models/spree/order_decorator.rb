module Spree
	Order.class_eval do

    # ---------------------------------------- Associations -----------------------------------------------------

    after_update :notify_driver

		def is_home_delivery_product_available?(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_type).include?("home_delivery")
		end

		def ready_to_pick_items(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_state).include?("ready_to_pick")
		end

    def items_state(item_ids)
      line_items.where(id: item_ids).collect(&:delivery_state).uniq.join
    end

    def delivery_address
      [ship_address.try(:address1), ship_address.try(:address2), ship_address.try(:city), ship_address.try(:state), ship_address.try(:country)].compact.join(", ")
    end

    def buyer_name
      [ship_address.first_name, ship_address.last_name].compact.join(" ")
    end

    def buyer_zipcode
      ship_address.zipcode
    end

    def get_store_line_items(store_id)
      line_items.joins(:product).where(spree_products: {store_id: store_id})
    end

    def get_home_delivery_line_item_ids(store_id)
      line_items.joins(:product).where(spree_products: {store_id: store_id}, spree_line_items: {delivery_type: "home_delivery"}).collect(&:id)
    end

    def eligible_for_free_delivery
      item_total.to_f >= 35
    end

    def self_pickup
      !line_items.collect(&:delivery_type).include?("home_delivery")
    end

    private

      def notify_driver
        if state == "canceled"
          REDIS_CLIENT.PUBLISH("listUpdate", {order_number: number}.to_json)
        end
      end

      def full_street_address
        [ship_address.address1, ship_address.address2, ship_address.city, ship_address.state, ship_address.country, ship_address.zipcode].compact.join(", ")
      end

	end
end