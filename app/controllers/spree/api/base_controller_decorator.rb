module Spree
	Api::BaseController.class_eval do 

		include Spree::Api::SessionsHelper

		def to_stringify_json obj, values = []
	    obj.each do |c_obj|
	  		main_hash = Hash.new
	  		c_obj.attributes.each do |k, v|
	  			main_hash[k.to_sym] = v.to_s
          if k == "depth"
            main_hash[:level] = v.to_s
          end
	  		end
	  		values.push(main_hash)
	  		if c_obj.children.present?
	  			main_hash["sub_category".to_sym] = to_stringify_json(c_obj.children, children_array = [])
	  		else
	  			main_hash["sub_category".to_sym] = []
	  		end
	  	end
	    return values
	  end

	  def to_stringify_product_json obj, user ,values = []
        obj.each do |p_obj|
          main_hash = Hash.new
          main_hash["id".to_sym] = p_obj.id.to_s
          main_hash["name".to_sym] = p_obj.name
          main_hash["description".to_sym] = p_obj.description.to_s
          main_hash["in_wishlist".to_sym] = p_obj.in_wishlist(user)
          main_hash["price".to_sym] = p_obj.cost_price.to_f.to_s
          main_hash["special_price".to_sym] = p_obj.price.to_f.to_s
          main_hash["discount".to_sym] = p_obj.discount.to_s
          main_hash["review".to_sym] = p_obj.comments.count.to_s
          if p_obj.total_on_hand > 0
            main_hash["total_on_hand".to_sym] = p_obj.total_on_hand.to_s
            main_hash["stock_status".to_sym] = "1"
          else
            main_hash["total_on_hand".to_sym] = ""
            main_hash["stock_status".to_sym] = "0"
          end

          main_hash["average_ratings".to_sym] = p_obj.average_ratings.to_s
          main_hash["total_rating".to_sym] =  p_obj.ratings.count.to_s
          main_hash["minimum_quantity".to_sym] = "1"
          values.push(main_hash)

        
          if p_obj.try(:variants) 
            variants_hash_final = []
            p_obj.variants.each do |variant|
              variants_hash = Hash.new
              variants_hash["id".to_sym] = variant.id.to_s
              variants_hash["price".to_sym] = variant.cost_price.to_s
              variants_hash["cost_price".to_sym] = variant.price.to_s
              variants_hash["discount".to_sym] = variant.discount.to_s
              variants_hash["total_on hand"] = variant.total_on_hand.to_s
              variants_hash["stock_status"] = variant.stock_status.to_s 

             
              variants_hash["option_name"] = variant.option_name

              if variant.images
                variants_hash["product_images".to_sym] = variant.product_images
                variants_hash_final.push(variants_hash)

              end
            end
            main_hash["variants".to_sym] = variants_hash_final
          else
            main_hash["variant".to_sym] = []
          end

          if p_obj.try(:images)
            main_hash["product_images".to_sym] = p_obj.product_images
          else
            main_hash["product_images".to_sym] = []
          end

          if p_obj.try(:taxons)
            taxon_arr = []
            p_obj.taxon_ids.each do |id|
              taxon_arr.push(id.to_s)
            end

            unless taxon_arr.empty?
              main_hash["category_ids".to_sym] = [taxon_arr.join(", ")]
            else
              main_hash["category_ids".to_sym] = []
            end
          end
        end
        return values
      end

		def generate_api_key(params, user_id)
			Spree::ApiToken.create({
		    token: (Digest::SHA1.hexdigest "#{Time.now.to_i}#{1}"),
		    latitude: params[:latitude],
		    longitude: params[:longitude],
		    user_device_id: params[:device_token],
		    user_id: user_id
		  })
		end

		def required_params_present?(params, * parameters)
      @errors = []
	    parameters.each do |param|
        if params[param].blank?
	        @response = error_response
          @errors << "#{param.to_s} cannot be left blank"
          @response[:message] = @errors.join(", ")	        
	      end
	    end
	    @errors.blank? ? true : false
	  end

	  def set_api_exception_handler_vars
	    @errors = []
	    @response = {:code => 0}
	  end

	  # Method to handle the API exceptions
	  def api_exception_handler(exception)
	    # @errors = []
	    # @errors << exception.message
	    # @response[:code] = 0
	    @response = error_response
	    @response[:message] = exception.message
	  end


      def to_stringify_checkout_json c_obj ,values = []
        order_hash=Hash.new
        bill_address_hash = Hash.new
        ship_address_hash = Hash.new
        skip_order_attributes = ["last_ip_address","created_by_id","approver_id","approved_at","confirmation_delivered","canceled_at","store_id"]
        #obj.each do |c_obj|
        checkout_step_arr = ["address" ,"delivery", "payment", "complete"]
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
          order_hash["checkout_steps".to_sym] = checkout_step_arr
          order_hash["token".to_sym] = c_obj.user.api_tokens.last.token.to_s
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
              
              variant_hash["stock_status"] = line_item.variant.stock_status.to_s
              variant_hash["option_name"] = line_item.variant.option_name

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

          if c_obj.state.eql?"payment" or c_obj.state.eql?"confirm" or c_obj.state.eql?"complete"
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
            order_hash["payment_method".to_sym] = []
          end
        #end

        if c_obj.try(:payments)
          payment_arr = []
          payment_attr = ["id" , "source_type" , "source_id", "amount", "payment_method_id", "response_code", "state", "avs_response"]
          c_obj.payments.each do |payment|
            payment_hash = Hash.new
            payment.attributes.each do |k1,v1|
              if payment_attr.include?k1
                payment_hash[k1.to_sym] = v1.to_s
              end
            end
            payment_method_hash = Hash.new
            payment_method_hash["id".to_sym] = payment.payment_method_id.to_s
            payment_method_hash["name".to_sym] = payment.payment_method.name.to_s
            payment_hash["payment_method".to_sym] = payment_method_hash

            payment_source_hash = Hash.new
            payment_source_hash["id".to_sym] = payment.source_id.to_s

            if payment.payment_method_id == 2
              payment_source_hash["month".to_sym] = payment.source.month.to_s
              payment_source_hash["year".to_sym] = payment.source.year.to_s
              payment_source_hash["cc_type".to_sym] = payment.source.cc_type.to_s
              payment_source_hash["last_digits".to_sym] = payment.source.last_digits.to_s
              payment_source_hash["name".to_sym] = payment.source.name.to_s
            elsif payment.payment_method_id == 3
              payment_source_hash["type".to_sym] = "pay_by_check"
            elsif payment.payment_method_id == 4
              payment_source_hash["paypal_email"] = payment.source.paypal_email.to_s
              payment_source_hash["braintree_last_digits"] = payment.source.braintree_last_digits.to_s
            else
              payment_source["message"] = "Invalid Source Id"
            end
            payment_hash["source".to_sym] = payment_source_hash
            payment_arr.push(payment_hash)
          end
          order_hash["payments".to_sym] = payment_arr
        else
          order_hash["payments".to_sym] = []
        end

      
        values.push(order_hash)
        return values
      end



	end
end