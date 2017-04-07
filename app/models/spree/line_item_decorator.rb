module Spree
	LineItem.class_eval do 

		belongs_to :driver, foreign_key: :driver_id, class_name: "Spree::User"

		after_update :notify_driver
		validate :ensure_for_valid_quantity

    searchable do

      time :updated_at

      string :brand_names, references: Spree::ProductProperty, multiple: true do
        unless self.variant.product.blank?
          self.product.product_properties.where(property_id: self.product.properties.where(name: "Brand").first.try(:id)).collect { |p| p.value }.flatten
        end
      end

      integer :taxon_ids, references: Spree::Taxon, multiple: true do
        unless self.product.blank?
          self.product.taxons.collect { |t| t.self_and_ancestors.map(&:id) }.flatten
        end
      end

      string :email , references: Spree::Order do
        if order.present?
          order.email
        end
      end

      integer :store_id, references: Spree::Product do
        unless product.blank?
          product.store_id
        end
      end

      string :product_names, references: Spree::Product, multiple: true  do
        unless product.blank?
          product.name.split(" ")
        end
      end

      double :product_price, references: Spree::Product , multiple: true do
        unless product.blank?
          product.price
        end
      end
    end

    # def brand_names
    #   self.variant.product.product_properties.where(property_id: self.variant.product.properties.where(name: "Brand").first.try(:id)).collect { |p| p.value }.flatten
    # end

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
  		CustomerReturnItem.where(line_item_id: self.id, order_id: order,status: "refunded").sum(:return_quantity)
  	end

  	def tax_rate
  		# variant.tax_category_id.present? ? variant.tax_category.tax_rates.first.amount.to_f : product.tax_category.tax_rates.first.amount.to_f 
      if self.tax_category.present?
        self.tax_category.tax_rates.first.amount.to_f
      else
        0
      end
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

    def return_item
      if Spree::CustomerReturnItem.where(line_item_id: self.id, refunded: 'Requested', status: 'Requested').present?
     		true
     	else
     		false
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