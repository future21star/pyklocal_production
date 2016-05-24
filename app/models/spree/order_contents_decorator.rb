module Spree
	OrderContents.class_eval do 
		def add(variant, quantity = 1, options = {}, delivery_type)
      timestamp = Time.current
      line_item = add_to_line_item(variant, quantity, options, delivery_type)
      options[:line_item_created] = true if timestamp <= line_item.created_at
      after_add_or_remove(line_item, options)
    end

    def remove(variant, quantity = 1, options = {}, delivery_type)
      line_item = remove_from_line_item(variant, quantity, options, delivery_type)
      after_add_or_remove(line_item, options)
    end 

    private

    def add_to_line_item(variant, quantity, options = {}, delivery_type)
      line_item = grab_line_item_by_variant(variant, false, options)

      if line_item
        line_item.quantity += quantity.to_i
        line_item.currency = currency unless currency.nil?
      else
        opts = { currency: order.currency }.merge ActionController::Parameters.new(options).
                                            permit(PermittedAttributes.line_item_attributes)
        line_item = order.line_items.new(quantity: quantity,
        																  delivery_type: delivery_type,
                                          variant: variant,
                                          options: opts)
      end
      line_item.target_shipment = options[:shipment] if options.has_key? :shipment
      line_item.save!
      line_item
    end

    def remove_from_line_item(variant, quantity, options = {}, delivery_type)
      line_item = grab_line_item_by_variant(variant, true, options)
      line_item.quantity -= quantity
      line_item.target_shipment= options[:shipment]

      if line_item.quantity.zero?
        order.line_items.destroy(line_item)
      else
        line_item.save!
      end

      line_item
    end

	end
end