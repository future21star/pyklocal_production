im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:logo_path])
if printable.has_attribute?('printable_id')
  printable = Spree::Order.find(printable.printable_id)
end
bill_address = Spree::Address.find(printable.bill_address_id)

if im && File.exist?(im.pathname)
  pdf.image im.filename, position: :right, height: 60, scale: Spree::PrintInvoice::Config[:logo_scale]
end

pdf.grid([0,0], [1,2]).bounding_box do
  pdf.move_down 4
  pdf.text "Bill From:", align: :left , :style => :bold
  pdf.text "#{bill_address.firstname} #{bill_address.lastname}"
  pdf.text "#{bill_address.address1}"
  pdf.text "#{bill_address.address2}" unless bill_address.address2.blank?
  pdf.text "#{bill_address.country.name}"
  pdf.text "#{bill_address.phone}"
  # pdf.text "#{bill_address.try(:site_url)}"
end