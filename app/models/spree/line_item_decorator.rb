module Spree
	LineItem.class_eval do 

		def product_name
			product.try(:name)
		end

		def seller_name
			product.store.try(:name)
		end

		def store_address
			product.store.try(:address)
		end

		def store_zipcode
			product.store.try(:zipcode)
		end

		def order_number
			order.number
		end

	end
end