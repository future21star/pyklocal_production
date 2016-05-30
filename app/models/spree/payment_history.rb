module Spree
	class PaymentHistory < ActiveRecord::Base

		self.table_name = "payment_histories"

		validates :transaction_number, :amount, presence: true
		validates :transaction_number, uniqueness: true
		validates_length_of :transaction_number, minimum: 10, maximum: 10, allow_blank: false

		belongs_to :user

		# before_create :add_due_amount
		# validate :transection_amount

		private

			def add_due_amount
				self.amount_due = user.amount_due - self.amount.to_f
			end

			def transection_amount
				if self.amount.to_f > user.amount_due
					self.errors.add(:base, "Transection amount should be less than amount due(Rs. #{user.amount_due})")
				end
			end
		
	end
end