module Spree
	class CustomerReturnItem < ActiveRecord::Base
		 self.table_name = "customer_return_items"
		 
		 belongs_to :order, class_name: "Spree::Order"
		 belongs_to :line_item, class_name: "Spree::LineItem"
		 belongs_to :store, class_name: "Merchant::Store"
	end
end
