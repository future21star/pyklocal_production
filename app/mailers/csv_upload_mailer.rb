class CsvUploadMailer < ActionMailer::Base
  default from: "prashant.mishra@w3villa.com"

  def start_uploading(seller)
    @seller = seller
    mail(to: @seller.email, subject: "Your Product Importing Has Started")
  end

  def uploading_complete(seller)
    @seller = seller
    mail(to: @seller.email, subject: "Your Product Importing Has Completed")
  end

end