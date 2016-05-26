module Spree
	LineItem.class_eval do 

		def product_name
			product.try(:name)
		end

		def store_location
			{lat: product.try(:store).try(:latitude), long: product.try(:store).try(:longitude)}
		end

		def seller_name
			product.store.try(:name)
		end

		def pickup_address
			product.store.try(:address)
		end

		def delivery_address
			[order.ship_address.address1, order.ship_address.address2, order.ship_address.city, order.ship_address.state, order.ship_address.country].compact.join(" ")
		end

		def buyer_name
			[order.ship_address.first_name, order.ship_address.last_name].compact.join(" ")
		end

		def buyer_zipcode
			order.ship_address.zipcode
		end

		def store_zipcode
			product.store.try(:zipcode)
		end

		def order_number
			order.number
		end

	end
end