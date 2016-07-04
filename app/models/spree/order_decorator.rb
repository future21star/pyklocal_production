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

    private

      def notify_driver
        if state == "canceled"
          REDIS_CLIENT.PUBLISH("listUpdate", {order_number: number}.to_json)
        end
      end

	end
end