class CsvUploadMailer < ActionMailer::Base
  default from: "sales@pyklocal.com"

  def start_uploading(seller)
    @seller = seller
    mail(from: "sales@pyklocal.com",to: @seller.email, subject: "Your Product Importing Has Started")
  end

  def uploading_complete(seller,errors)
    @seller = seller
    @errors = errors
    mail(from: "sales@pyklocal.com",to: @seller.email, subject: "Your Product Importing Has Completed")
  end

end