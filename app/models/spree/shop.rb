module Spree
  class Shop < ActiveRecord::Base
    self.table_name = "spree_products"

    searchable do
      text :name
    end

  end
end