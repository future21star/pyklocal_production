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

	end
end