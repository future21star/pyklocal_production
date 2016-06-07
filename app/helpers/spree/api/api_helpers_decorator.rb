Spree::Api::ApiHelpers.module_eval do 

	def get_response
		{
			code: 1,
			message: "Successfully saved"
		}
	end

	def error_response
		{
			code: 0,
			message: ""
		}
	end
	
end