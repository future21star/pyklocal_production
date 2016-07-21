module Merchant
  class UserStoreRating < ActiveRecord::Base

    self.table_name = "users_stores_ratings"

    belongs_to :user, foreign_key: :user_id, class_name: "Spree::User"
    belongs_to :store

    validate :uniq_record, on: :create

    private

      def uniq_record
        if Merchant::UserStoreRating.where(user_id: self.user_id, store_id: self.store_id).present?
          self.errors.add(:base, "You have already rated this store.")
        end
      end
    
  end
end