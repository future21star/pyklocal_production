module Spree
	class CustomerReturnItem < ActiveRecord::Base
		 self.table_name = "customer_return_items"
		 
		 belongs_to :order
		 belongs_to :line_item
		 belongs_to :store, class_name: "Merchant::Store"
	end
end
