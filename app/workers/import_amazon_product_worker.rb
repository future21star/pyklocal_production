# class ImportAmazonProductWorker
#   include Sidekiq::Worker
#   sidekiq_options retry: false

#   def perform(amazon_products)
#     amazon_products.each do |raw_product|
#       description = raw_product.try(:editorial_reviews).try(:editorial_review).try(:content)
#       if raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100 == 0
#         offer_price = raw_product.item_attributes.try(:list_price).try(:amount).to_f/100
#       else
#         offer_price = raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100
#       end
#       image_u = raw_product.large_image.try(:url)
#       sku = raw_product.item_attributes.title[0..2].upcase+SecureRandom.hex(5).upcase
#       asin_no = raw_product.asin
#       @product = Spree::Product.where(asin: raw_product.asin,store_id: current_spree_user.stores.first.try(:id)).first
#       if @product.blank?
#         @product = Spree::Product.create({name: raw_product.item_attributes.title, sku: sku, description: description, price: offer_price, available_on: Time.zone.now.strftime("%Y/%m/%d"), shipping_category_id: Spree::ShippingCategory.find_by_name("Default").try(:id), image_url: raw_product.large_image.try(:url), store_id: current_spree_user.stores.first.try(:id), asin: asin_no}) 
#         raw_product.item_attributes.each do |amazon_products_properties|
#           if amazon_products_properties[1].class.to_s == "REXMLUtiliyNodeString"
#             property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
#             product_property = @product.product_properties.build(value: amazon_products_properties[1])
#             product_property.property = property  
#           elsif amazon_products_properties[1].class.to_s == "Array"
#             property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
#             amazon_products_properties[1].each do |ap|
#               product_property = @product.product_properties.build({value: ap})
#               product_property.property = property
#             end
#           end
#           if @product.save
#             success = true
#           end
#         end
#         raw_product.image_sets.image_set.each do |product_images|
#           thumb_image = @product.images.build(attachment: product_images.try(:large_image).try(:url))
#           thumb_image.save
#         end
#       else
#         return  
#       end
#     end
#   end

# end