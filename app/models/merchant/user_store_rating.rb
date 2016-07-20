module Merchant
  class UserStoreRating < ActiveRecord::Base

    self.table_name = "users_stores_ratings"

    belongs_to :user, foreign_key: :user_id, class_name: "Spree::User"
    belongs_to :store
    
  end
end