class Rating < ActiveRecord::Base

  belongs_to :rateable, polymorphic: true
  belongs_to :user, foreign_key: :user_id, class_name: "Spree::User"
  validate :uniq_record, on: :create

  private

    def uniq_record
      if Rating.where(user_id: self.user_id, rateable_id: self.rateable_id, rateable_type: self.rateable_type).present?
        self.errors.add(:base, "You have already rated this")
      end
    end
    
end