header = [
  pdf.make_cell(content: Spree.t(:sku)),
  pdf.make_cell(content: Spree.t(:item_description)),
  pdf.make_cell(content: Spree.t(:options)),
  pdf.make_cell(content: Spree.t(:price)),
  pdf.make_cell(content: Spree.t(:qty)),
  pdf.make_cell(content: Spree.t(:total))
]
data = [header]

invoice.line_items.each do |item|
  row = [
    item.sku,
    item.name,
    item.variant.options_text,
    item.display_price.to_s,
    item.quantity,
    item.display_amount.to_html
  ]
  data += [row]
end

column_widths = [0.13, 0.37, 0.185, 0.12, 0.075, 0.12].map { |w| w * pdf.bounds.width }

pdf.table(data, column_widths: column_widths, header: true, position: :center) do
 row(0).style background_color: "F0F0F0"
 cells.padding = 12
 cells.borders = []
 row(0).borders = [:bottom]
 row(0).border_width = 1
 row(0).font_style = :bold
 row(0..10  ).columns(0..5).borders = [:bottom]
end

# pdf.table(data, header: true, position: :center, column_widths: column_widths, :border_width => 1 , :borders => [:bottom]) do
#   row(0).style align: :center, font_style: :bold
#   column(0..2).style align: :left
#   column(3..6).style align: :right
# end
