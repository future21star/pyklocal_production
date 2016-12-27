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

		def promo_amount
	    promo = order.promotion
	    return promo_total unless promo
	    order_total = order.item_total
	    return 0.0 unless order_total != 0.0
	    (promo.amount * amount) / order_total
  	end

  	 def discounted_amount
    	amount + promo_amount
  	end

  	def return_quantity order
  		CustomerReturnItem.where(line_item_id: self.id, order_id: order).sum(:return_quantity)
  	end

		def seller_name
			product.store.try(:name)
		end

		def state
			delivery_state
		end

    def line_item_store
      product.store
    end

		def pickup_address
			product.store.try(:address)
		end

		def copy_tax_category
      if variant
        self.tax_category_id = variant.tax_category_id
      end
    end

    def total_amount
      self.quantity * self.price.to_f
    end
    
		def order_number
			order.number
		end

    def copy_tax_category
      if variant
        self.tax_category = product.tax_category
      end
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