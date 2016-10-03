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

	  def to_stringify_product_json obj, values = []
        obj.each do |p_obj|
          main_hash = Hash.new
          main_hash["id".to_sym] = p_obj.id.to_s
          main_hash["name".to_sym] = p_obj.name
          main_hash["description".to_sym] = p_obj.description.to_s

          if p_obj.total_on_hand > 0
            main_hash["total_on_hand".to_sym] = p_obj.total_on_hand.to_s
            main_hash["stock_status".to_sym] = "1"
          else
            main_hash["total_on_hand".to_sym] = ""
            main_hash["stock_status".to_sym] = "0"
          end

          main_hash["average_ratings".to_sym] = p_obj.average_ratings.to_s
     
         
          main_hash["price".to_sym] = p_obj.price.to_s
          values.push(main_hash)

        
          if p_obj.try(:variants) 
            variants_hash_final = []
            p_obj.variants.each do |variant|
              variants_hash = Hash.new
              variants_hash["id"] = variant.id.to_s
              variants_hash["price"] = variant.price.to_s
              variants_hash["total_on hand"] = variant.total_on_hand.to_s
              variants_hash["stock_status"] = variant.stock_status.to_s 

             
              variants_hash["option_name"] = variant.option_name

              if variant.images
                variants_hash["product_images"] = variant.product_images
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

	end
end