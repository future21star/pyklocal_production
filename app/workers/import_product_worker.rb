class ImportProductWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(csv_path, seller_email)
    seller = Spree::User.find_by_email(seller_email)
    CsvUploadMailer.start_uploading(seller).deliver
    shipping_category_id = Spree::ShippingCategory.find_by_name("Default").try(:id)
    store_id = seller.stores.first.try(:id)
    errors = []
    number_of_rows = 0
    total_product = 0
    exception_flag = true
    total_product_count = 0 
    error_count = 0
    begin
      p "1111111111"
      CSV.foreach(csv_path) do |row|
        total_product_count += 1
        p "---------------------------------------------------"
        p row.include?("Product Name")
        p row.include?("Description")
        unless row.include?("Product Name") && row.include?("Description")
          number_of_rows = number_of_rows + 1
         unless row[0].blank? 
            sku = row[0][0..2].upcase+SecureRandom.hex(5).upcase
            error_count += Spree::Product.analize_and_create(row[0], row[2], sku, Time.zone.now.strftime("%Y/%m/%d"), row[1], shipping_category_id, row[6], store_id, row[7], row[8], row[9], row[4], row[10], row[5], row[3],row[11],errors, number_of_rows,total_product)
          else
            Hash error = Hash.new
            error["CSV Error".to_sym] = "row " + number_of_rows.to_s + " does not have product name"
            errors.push(error)
          end
        end
      end
    rescue Exception => e
      exception_flag = false
      Hash error = Hash.new
      error["CSV Error".to_sym] =  "rows #{number_of_rows} : #{e.message}"
      errors.push(error)
    ensure
      if number_of_rows == 0 &&  exception_flag == true
        Hash error = Hash.new
        error["CSV Error".to_sym] = "CSV File is blank"
        errors.push(error)
      end

      p errors
      p total_product
      debugger
      CsvUploadMailer.uploading_complete(seller, total_product_count - 1, errors, error_count).deliver
    end
  end
end