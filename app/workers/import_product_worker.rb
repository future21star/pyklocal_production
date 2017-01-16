class ImportProductWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(csv_path, seller_email)
    seller = Spree::User.find_by_email(seller_email)
    CsvUploadMailer.start_uploading(seller).deliver
    shipping_category_id = Spree::ShippingCategory.find_by_name("Default").try(:id)
    store_id = seller.stores.first.try(:id)
    CSV.foreach(csv_path) do |row|
      unless row.include?("Product Name") && row.include?("Description")
        p "---------------------------------------------------"
        sku = row[0][0..2].upcase+SecureRandom.hex(5).upcase
        Spree::Product.analize_and_create(row[0], row[2], sku, Time.zone.now.strftime("%Y/%m/%d"), row[1], shipping_category_id, row[6], store_id, row[7], row[8], row[9], row[4], row[10], row[5], row[3])
      end
    end
    CsvUploadMailer.uploading_complete(seller).deliver
  end
end