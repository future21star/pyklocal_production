module Spree
  class Wishlist < ActiveRecord::Base

    self.table_name = "wishlists"

    belongs_to :user
    belongs_to :variant
    
  end
end