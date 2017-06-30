im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:logo_path])
if printable.has_attribute?('printable_id')
	bill_address = Spree::Order.find(printable.printable_id).store
end

if im && File.exist?(im.pathname)
  pdf.image im.filename, position: :right, height: 60, scale: Spree::PrintInvoice::Config[:logo_scale]
end

pdf.grid([0,0], [1,2]).bounding_box do
  pdf.move_down 4
  pdf.text "Bill From:", align: :left , :style => :bold
  pdf.text "#{bill_address.name}"
  pdf.text "#{bill_address.address}"
  pdf.text "#{bill_address.country}"
  pdf.text "#{bill_address.phone_number}"
  pdf.text "#{bill_address.try(:site_url)}"
end