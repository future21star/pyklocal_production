module Spree::Api::SessionsHelper
	def get_response(user)
		{
  		code: 1,
  		message: "Registered successfully!",
  		user: user.as_json({
  			only: [:first_name, :last_name, :spree_api_key]
  		}).merge({token: generate_api_key(params, user.id).token})
  	}
	end

	def error_response
		{
			code: 0,
			message: ""
		}
	end
end