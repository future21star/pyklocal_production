module Spree
	Api::BaseController.class_eval do 

		def generate_api_key(params, user_id)
			Spree::ApiToken.create({
		    token: (Digest::SHA1.hexdigest "#{Time.now.to_i}#{1}"),
		    latitude: params[:latitude],
		    longitude: params[:longitude],
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
	    @errors = []
	    @errors << exception.message
	    @response[:code] = 0
	  end

	end
end