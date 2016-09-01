module Spree
	Api::BaseController.class_eval do 

		include Spree::Api::SessionsHelper

		def to_stringify_json obj, values = []
	    obj.each do |c_obj|
	  		main_hash = Hash.new
	  		c_obj.attributes.each do |k, v|
	  			main_hash[k.to_sym] = v.to_s
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
	    parameters.each do |param|
	      if params[param].blank?
	        @response[:code] = 0
	        @errors << "#{param.to_s} cannot be left blank"
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