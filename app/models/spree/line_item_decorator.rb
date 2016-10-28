module Spree
	LineItem.class_eval do 

		belongs_to :driver, foreign_key: :driver_id, class_name: "Spree::User"

		after_update :notify_driver
		validate :ensure_for_valid_quantity

		def product_name
			product.try(:name)
		end

		def product_image_url
			product.images.first.try(:attachment).try(:url)
		end

		def seller_name
			product.store.try(:name)
		end

		def state
			delivery_state
		end

		def pickup_address
			product.store.try(:address)
		end

		def copy_tax_category
      if variant
        self.tax_category_id = variant.tax_category_id
      end
    end

		def order_number
			order.number
		end

		private

			def notify_driver
				if self.changes.include?(:delivery_state)
					REDIS_CLIENT.PUBLISH("listUpdate", {order_number: order.number, store_name: product.try(:store).try(:name)}.to_json)
				end
			end

      def ensure_for_valid_quantity
      	if self.changes.include?(:quantity)
        	if quantity > 500
        		self.errors.add(:base, "Please enter reasonable quantity")
        	end
        end
      end

	end
end