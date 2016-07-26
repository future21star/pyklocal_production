module Spree
	LineItem.class_eval do 

		belongs_to :driver, foreign_key: :driver_id, class_name: "Spree::User"

		after_update :notify_driver

		def product_name
			product.try(:name)
		end

		def product_image_url
			product.images.first.try(:attachment).try(:url)
		end

		# def store_location
		# 	{lat: product.try(:store).try(:latitude).to_f, lng: product.try(:store).try(:longitude).to_f}
		# end

		def seller_name
			product.store.try(:name)
		end

		def state
			delivery_state
		end

		def pickup_address
			product.store.try(:address)
		end

		# def delivery_address
		# 	[order.ship_address.try(:address1), order.ship_address.try(:address2), order.ship_address.try(:city), order.ship_address.try(:state), order.ship_address.try(:country)].compact.join(", ")
		# end

		# def buyer_name
		# 	[order.ship_address.first_name, order.ship_address.last_name].compact.join(" ")
		# end

		# def buyer_zipcode
		# 	order.ship_address.zipcode
		# end

		# def store_zipcode
		# 	product.store.try(:zipcode)
		# end

		def order_number
			order.number
		end

		private

			def notify_driver
				if self.changes.include?(:delivery_state)
					REDIS_CLIENT.PUBLISH("listUpdate", {order_number: order.number, store_name: product.try(:store).try(:name)}.to_json)
				end
			end

	end
end