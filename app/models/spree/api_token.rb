module Spree
	class ApiToken < ActiveRecord::Base

		self.table_name = "api_tokens"

		belongs_to :user

	end
end