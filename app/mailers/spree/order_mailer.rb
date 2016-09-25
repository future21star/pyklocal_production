module Spree
  class OrderMailer < BaseMailer
    default from: 'admin@pyklocal.com'
    
    def confirm_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      filename = "Invoice_#{@order.number}_#{Time.now.strftime('%Y%m%d')}.pdf"

      admin_controller = Spree::Admin::OrdersController.new
      invoice = admin_controller.render_to_string(:layout => false , :template => "spree/printables/order/invoice.pdf.prawn", :type => :prawn, :locals => {:@doc => @order})

      attachments[filename] = {
        mime_type: 'application/pdf',
        content: invoice
      }

      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.confirm_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: "admin@pyklocal.com", subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.cancel_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end
  end
end