Spree::Calculator::DefaultTax.class_eval do

  # def compute_order(order)
  # 	p "***************************************************************"
  # 	p order
  # 	rate = self.calculable
		# line_items = order.line_items.select { |i| i.product.tax_category== rate.tax_category }
		# pre_discount_total = line_items.inject(0) {|sum, line_item|
		# 	sum += line_item.total
		# }
		# rate * (pre_discount_total + order.adjustments.promotion.eligible.sum(:amount))
  # end
end