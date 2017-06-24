printable = Spree::Order.find(printable.printable_id)
if printable.get_order_home_delivery_line_items_ids.count == 0
  unless Spree::Address.where(id: printable.bill_address_id).empty?
  	ship_address = Spree::Address.find(printable.bill_address_id)
  end
else
  unless Spree::Address.where(id: printable.ship_address_id).empty?
	 ship_address = Spree::Address.find(printable.ship_address_id) 
  end
end

if ship_address.blank?
  ship_address = Spree::Address.last
end
data = [ ["Invoice Number #", "#{printable.number}"],
 ["Invoice Date:", "#{printable.completed_at}"],
 ["Order Total:", "#{printable.display_total.to_s}"]
 ]

pdf.table(data, header: true, position: :right) do
 row(2).style background_color: "F0F0F0"
 cells.padding = 12
 cells.borders = []
 row(0..2).borders = [:bottom]
 row(0..2).border_width = 1
 row(0..2).font_style = :bold
 row(0..2).columns(0..4).borders = [:bottom]
end

pdf.grid([0,1], [1,0]).bounding_box do
	if printable.get_order_home_delivery_line_items_ids.count == 0
 	  pdf.text Spree.t(:billing_address), align: :left , :style => :bold
 	else
 		pdf.text Spree.t(:shipping_address), align: :left , :style => :bold
 	end
  pdf.text "#{ship_address.firstname} #{ship_address.lastname}"
  pdf.text "#{ship_address.address1}"
  pdf.text "#{ship_address.address2}" unless ship_address.address2.blank?
  pdf.text "#{ship_address.city}, #{ship_address.state_text} #{ship_address.zipcode}"
  pdf.text "#{ship_address.country.name}"
  pdf.text "#{ship_address.phone}"
  pdf.text "#{printable.email}"
end


