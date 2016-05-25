module Spree
	class UserDevice < ActiveRecord::Base

		self.table_name = "user_devices"

		belongs_to :user

		validate :valid_user

		private

			def valid_user
				if Spree::User.where(id: self.user_id).blank?
					self.errors.add(:base, "Invalid user id, User not found")
				end
			end

	end
end