im = Rails.application.assets.find_asset(Spree::PrintInvoice::Config[:logo_path])

if im && File.exist?(im.pathname)
  pdf.image im.filename, vposition: :top, height: 80, scale: Spree::PrintInvoice::Config[:logo_scale]
end

pdf.grid([0,3], [1,4]).bounding_box do
  pdf.text Spree.t(scope: :print_invoice), align: :right, style: :bold, size: 11
  pdf.move_down 4

  pdf.text Spree.t(:invoice_number, scope: :print_invoice, number: printable.number), align: :right
  pdf.move_down 2
  pdf.text Spree.t(:invoice_date, scope: :print_invoice, date: I18n.l(printable.created_at)), align: :right
end
