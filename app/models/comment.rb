class Comment < ActiveRecord::Base

  belongs_to :commentable, polymorphic: true
  belongs_to :user, foreign_key: :user_id, class_name: "Spree::User"

  validate :uniq_record, on: :create

  private

    def uniq_record
      if Comment.where(user_id: self.user_id, commentable_id: self.commentable_id, commentable_type: self.commentable_type).present?
        self.errors.add(:base, "You have already commented on this")
      end
    end

end