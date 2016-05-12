class EmailToken < ActiveRecord::Base
	belongs_to :resource, polymorphic: true
	after_create :make_valid

	private

	def make_valid
		resource.email_tokens.where(is_valid: true).first.try(:update_attributes, {is_valid: false})
		self.update_attributes(is_valid: true)
	end
end
