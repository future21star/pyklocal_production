Spree::Api::ApiHelpers.module_eval do 

	def get_response
		{
			status: "1",
			message: "Successfully saved"
		}
	end

	def error_response
		{
			sucess: "0",
			message: ""
		}
	end
	
end