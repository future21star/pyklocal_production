class SubscribeUserToMailingListJob < ActiveJob::Base
	queue_as :default
	require 'gibbon'

	def perform(user)
		gibbon = Gibbon::Request.new(api_key: "9a44b373a0a0b5b84c34c91276080375-us15")
		gibbon.timeout = 10
		gibbon.lists("ebd0dc8c03").members.create(
			body:{
				email_address: user.email,
				status: "subscribed",
				merge_fields: {FNAME: user.first_name, LNAME: user.last_name}
				})
	end
end