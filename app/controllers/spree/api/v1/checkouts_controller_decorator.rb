module Spree
	Api::V1::CheckoutsController.class_eval do
		
	    def next
	      authorize! :update, @order, order_token
	      @order.next!
	      render json: {
	      	status: "1",
	      	order_detail: to_stringify_checkout_json(@order, [])
	      }
	    rescue Exception => e
	      render json: {
	      	status: "0",
	      	message: "could not transist",
	      	error: e.message.to_s
	      }
	    end

	      def update
          authorize! :update, @order, order_token

          if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
            if current_api_user.has_spree_role?('admin') && user_id.present?
              @order.associate_user!(Spree.user_class.find(user_id))
            end

            return if after_update_attributes

            if @order.completed? || @order.next
              state_callback(:after)
              render json: {
	      				status: "1",
	      				order_detail: to_stringify_checkout_json(@order, [])
	      		}
            else
              respond_with(@order, default_template: 'spree/api/v1/orders/could_not_transition', status: 422)
            end
          else
            invalid_resource!(@order)
          end
        end


	    private 

	   	def to_stringify_checkout_json c_obj ,values = []
	   		order_hash=Hash.new
	   		bill_address_hash = Hash.new
	   		ship_address_hash = Hash.new
	   		skip_order_attributes = ["last_ip_address","created_by_id","approver_id","approved_at","confirmation_delivered","guest_token","canceled_at","store_id"]
	   		#obj.each do |c_obj|
	   			c_obj.attributes.each do |k,v|
	   					unless skip_order_attributes.include? k
	   						if k.eql?"bill_address_id"  
	   							if v
	   								bill_country_hash = Hash.new
	   								bill_state_hash = Hash.new
	   								c_obj.bill_address.attributes.each do |k1,v1|
	   									if k1.eql?"state_id"
	   										c_obj.bill_address.state.attributes.each do |k2,v2|
	   											if k2.eql?"country_id"
	   												c_obj.bill_address.state.country.attributes.each do |k3,v3|
	   													bill_country_hash[k3.to_sym] = v3.to_s
	   												end
	   												bill_address_hash["country".to_sym] = bill_country_hash
	   											end
	   											bill_state_hash[k2.to_sym] = v2.to_s
	   										end
	   										bill_address_hash["state".to_sym] = bill_state_hash
	   									end
	   									bill_address_hash[k1.to_sym] = v1.to_s
	   								end
	   							end
	   						end

	   						if k.eql?"ship_address_id"  
	   							if v
	   								ship_country_hash = Hash.new
	   								ship_state_hash = Hash.new
	   								c_obj.bill_address.attributes.each do |k1,v1|
	   									if k1.eql?"state_id"
	   										c_obj.bill_address.state.attributes.each do |k2,v2|
	   											if k2.eql?"country_id"
	   												c_obj.bill_address.state.country.attributes.each do |k3,v3|
	   													ship_country_hash[k3.to_sym] = v3.to_s
	   												end
	   												ship_address_hash["country".to_sym] = ship_country_hash
	   											end
	   											ship_state_hash[k2.to_sym] = v2.to_s
	   										end
	   										ship_address_hash["state".to_sym] =ship_state_hash
	   									end
	   									ship_address_hash[k1.to_sym] = v1.to_s
	   								end
	   							end
	   						end

	   						order_hash[k.to_sym] = v.to_s
	   					end 
	   			end

	   			if bill_address_hash
	   				order_hash["bill_address".to_sym] = bill_address_hash
	   			else
	   				order_hash["bill_address".to_sym] = []
	   			end

	   			if ship_address_hash
	   				order_hash["ship_address".to_sym] = ship_address_hash
	   			else
	   				order_hash["ship_address".to_sym] = []
	   			end
	   			if c_obj.try(:line_items)
	   				line_item_arr = []
	   				c_obj.line_items.each do|line_item|
	   					line_items_hash = Hash.new
	   					line_items_hash["id".to_sym] = line_item.id.to_s
	   					line_items_hash["quantity".to_sym] = line_item.quantity.to_s
	   					line_items_hash["price".to_sym] = line_item.price.to_s
	   					line_items_hash["variant_id".to_sym] = line_item.variant.to_s
	   					variant_hash = Hash.new
	   					line_item.variant.attributes.each do|k,v|
	   							variant_hash[k.to_sym] = v.to_s
	   					end
	   					
	   					if line_item.variant.images
	   						variant_hash["images".to_sym] = line_item.variant.product_images
	   					else
	   						variant_hash["images".to_sym] = []
	   					end

	   					line_items_hash["variants"] = variant_hash
	   					line_item_arr.push(line_items_hash)
	   				end
	   				order_hash["line_items"] = line_item_arr
	   			else
	   				order_hash["line_items"] = []
	   			end

	   			if c_obj.try(:shipments)
	   				shipment_attr =["id","number","cost","shipped_at","state","order_id","adjustment_total"]
	   				shipment_hash = Hash.new
	   				c_obj.shipments.first.attributes.each do |k,v|
	   					if shipment_attr.include?k
	   						shipment_hash[k.to_sym] = v.to_s
	   					end	
	   				end
	   				shipping_rate_arr =[]
	   				shipping_method_arr = []
	   				c_obj.shipments.first.shipping_rates.each do |shipping_rate|
	   					shipping_rate_hash = Hash.new
	   					shipping_rate_hash["id"] = shipping_rate.id.to_s
	   					shipping_rate_hash["name"] = shipping_rate.shipping_method.name.to_s
	   					shipping_rate_hash["cost"] = shipping_rate.cost.to_s
	   					shipping_rate_hash["shipping_method_id"] = shipping_rate.shipping_method_id.to_s
	   					shipping_rate_hash["shipping_method_code"] = shipping_rate.shipping_method.code.to_s
	   					if shipping_rate.selected
	   						shipping_rate_hash["selected".to_sym] = 'true'
	   						shipment_hash["selected_shipping_rate".to_sym] = shipping_rate_hash
	   						shipping_rate_arr.push(shipping_rate_hash)
	   					else
	   						shipping_rate_hash["selected"] = 'false'
	   						shipping_rate_arr.push(shipping_rate_hash)
	   					end
	   				end
	   				shipment_hash["shipping_rates".to_sym] = shipping_rate_arr
	   					shipping_method_arr = []
	   					c_obj.shipments.first.shipping_methods.each do |shipping_method|
		   					shipping_method_hash =Hash.new
		   					shipping_method_hash["id"] = shipping_method.id.to_s
		   					shipping_method_hash["name"] = shipping_method.name.to_s
		   					shipping_method_hash["shipping_method_code"] = shipping_method.code.to_s
		   					shipping_zone_arr = []
		   					shipping_category_arr = []
		   					shipping_method.zones.each do |zone|
		   						zone_hash = Hash.new
		   						zone_hash["id".to_sym] = zone.id.to_s
		   						zone_hash["name".to_sym] = zone.name.to_s
		   						zone_hash["description".to_sym]= zone.description.to_s
		   						shipping_zone_arr.push(zone_hash)
		   					end
		   					shipping_method_hash["zones".to_sym] = shipping_zone_arr

		   					shipping_categories = []
		   					shipping_method.shipping_categories.each do |shipping_category|
		   						shipping_category_hash = Hash.new
		   						shipping_category_hash["id".to_sym] = shipping_category.id.to_s
		   						shipping_category_hash["name".to_sym] = shipping_category.name.to_s
		   						shipping_categories.push(shipping_category_hash)
	   						end
	   						shipping_method_hash["shipping_categories".to_sym] = shipping_categories
	   						shipping_method_arr.push(shipping_method_hash)
	   					end
	   					shipment_hash["shipping_methods".to_sym] = shipping_method_arr
	   					order_hash["shipment".to_sym] = shipment_hash
	   			else
	   				order_hash["shipments".to_sym] = []
	   			end

	   			if c_obj.state.eql?"payment"
	   				payment_method_arr = []
	   				c_obj.available_payment_methods.each do |payment_method|
	   					payment_method_hash = Hash.new
	   					payment_method_hash["id".to_sym] = payment_method.id.to_s
	   					payment_method_hash["name".to_sym] = payment_method.name.to_s
	   					payment_method_hash["method_type".to_sym] = payment_method.method_type.to_s
	   					payment_method_arr.push(payment_method_hash)

	   				end
	   				order_hash["payment_methods".to_sym] = payment_method_arr
	   			else
	   				order_hash["payment"] = []
	   			end
	   		#end

	   	
	   		values.push(order_hash)
	   		return values
	   	end

	   	 
	end
end