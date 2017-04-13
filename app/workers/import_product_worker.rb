class ImportProductWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(csv_path, seller_email)
    seller = Spree::User.find_by_email(seller_email)
    CsvUploadMailer.start_uploading(seller).deliver
    shipping_category_id = Spree::ShippingCategory.find_by_name("Default").try(:id)
    store_id = seller.stores.first.try(:id)
    errors = []
    number_of_rows = 0;
    CSV.foreach(csv_path) do |row|
      p "---------------------------------------------------"
      p row.include?("Product Name")
      p row.include?("Description")
      unless row.include?("Product Name") && row.include?("Description")
        number_of_rows = number_of_rows + 1 ;
       unless row[0].blank? 
          sku = row[0][0..2].upcase+SecureRandom.hex(5).upcase
          Spree::Product.analize_and_create(row[0], row[2], sku, Time.zone.now.strftime("%Y/%m/%d"), row[1], shipping_category_id, row[6], store_id, row[7], row[8], row[9], row[4], row[10], row[5], row[3],row[11],errors, number_of_rows)
        else
          Hash error = Hash.new
          error["CSV Error".to_sym] = "row " + number_of_rows.to_s + " does not have product name"
          errors.push(error)
        end
      end
    end
    p "222222222222222222222222"
    if number_of_rows == 0
      Hash error = Hash.new
      error["CSV Error".to_sym] = "CSV File is blank"
      errors.push(error)
    end
    p errors
    CsvUploadMailer.uploading_complete(seller,errors).deliver
  end
end