module Spree
	class ApiToken < ActiveRecord::Base

		self.table_name = "api_tokens"

		belongs_to :user
		belongs_to :user_device

	end
end