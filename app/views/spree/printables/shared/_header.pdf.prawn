im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:logo_path])
bill_address = printable.store

if im && File.exist?(im.pathname)
  pdf.image im.filename, position: :right, height: 60, scale: Spree::PrintInvoice::Config[:logo_scale]
end

pdf.grid([0,0], [1,2]).bounding_box do
  pdf.move_down 4
  pdf.text "Bill From:", align: :left , :style => :bold
  pdf.text "#{bill_address.name}"
  pdf.text "#{bill_address.street_number}, #{bill_address.city} #{bill_address.state} #{bill_address.zipcode}"
  pdf.text "#{bill_address.country}"
  pdf.text "#{bill_address.phone_number}"
  pdf.text "#{bill_address.try(:site_url)}"
end