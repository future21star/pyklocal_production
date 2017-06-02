class CsvUploadMailer < ActionMailer::Base
  default from: "sales@pyklocal.com"

  def start_uploading(seller)
    @seller = seller
    mail(from: "sales@pyklocal.com",to: @seller.email, subject: "Your Product Importing Has Started")
  end

  def uploading_complete(seller,total_product_count,errors, error_count)
    @seller = seller
    @errors = errors
    @total_count = total_product_count
    @error_count = error_count
    mail(from: "sales@pyklocal.com",to: @seller.email, subject: "Your Product Importing Has Completed")
  end

end