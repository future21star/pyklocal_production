# TOTALS
totals = []

# Subtotal
totals << [pdf.make_cell(content: Spree.t(:subtotal)), invoice.display_item_total.to_s]

# Adjustments
invoice.adjustments.each do |adjustment|
  totals << [pdf.make_cell(content: adjustment.label), adjustment.display_amount.to_s]
end

invoice.all_adjustments.each do |adjustment|
  totals << [pdf.make_cell(content: adjustment.label), ActionController::Base.helpers.number_to_currency(adjustment.amount.to_f)]
end

# Shipments
invoice.shipments.each do |shipment|
  unless shipment.shipping_method.name == "Free Delivery"
    totals << [pdf.make_cell(content: shipment.shipping_method.name), shipment.display_cost.to_s]
  end
end

# Totals
totals << [pdf.make_cell(content: Spree.t(:order_total)), invoice.display_total.to_s]

# Payments
total_payments = 0.0
invoice.payments.each do |payment|
  totals << [
    pdf.make_cell(
      content: Spree.t(:payment_via,
      gateway: (payment.source_type || Spree.t(:unprocessed, scope: :print_invoice)),
      number: payment.number,
      date: I18n.l(payment.updated_at.to_date, format: :long),
      scope: :print_invoice)
    ),
    payment.display_amount.to_s
  ]
  total_payments += payment.amount
end

totals_table_width = [0.875, 0.125].map { |w| w * pdf.bounds.width }
pdf.table(totals, position: :right) do
  row(2).style background_color: "F0F0F0"
  row(0..6).style align: :right
  cells.padding = 12
  cells.borders = []
  row(0).borders = [:bottom]
  row(0).border_width = 1
  row(0).font_style = :bold
  row(0..10  ).columns(0..6).borders = [:bottom]
end

# pdf.grid([0,4], [4,0]).bounding_box do
#   pdf.text "NOTES/MEMO", align: :left , :style => :bold
#   pdf.text "*Keep this invoice and manufacturer box for warranty purposes.", align: :left 
# end
