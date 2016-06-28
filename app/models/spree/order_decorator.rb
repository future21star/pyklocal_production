module Spree
	Order.class_eval do 

		def is_home_delivery_product_available?(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_type).include?("home_delivery")
		end

		def ready_to_pick_items(item_ids)
			line_items.where(id: item_ids).collect(&:delivery_state).include?("ready_to_pick")
		end

	end
end