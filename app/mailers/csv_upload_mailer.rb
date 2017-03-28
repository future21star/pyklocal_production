class CsvUploadMailer < ActionMailer::Base
  default from: "sales@pyklocal.com"

  def start_uploading(seller)
    @seller = seller
    mail(to: @seller.email, subject: "Your Product Importing Has Started")
  end

  def uploading_complete(seller)
    @seller = seller
    mail(to: @seller.email, subject: "Your Product Importing Has Completed")
  end

end