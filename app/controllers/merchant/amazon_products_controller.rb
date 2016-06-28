require 'uri'
class Merchant::AmazonProductsController < Merchant::ApplicationController

	def fetch
		if  ["keyword", nil].include?(params[:by])
			
			if params[:keywords].present?
				@amazon_products, @total_results = AMAZON_CLIENT.search_keywords(params[:keywords], {SearchIndex: (params[:serch_index] || "All"), ResponseGroup: (params[:response_type] || "Medium"), ItemPage: (params[:item_page] || 1)})
			elsif params[:node].present?
				@amazon_products = AMAZON_CLIENT.browse_node(params[:node])
			end
		else
			
			URI.parse(params[:url])
		end
		# render json: @amazon_products
	end

	def new
		raw_product = AMAZON_CLIENT.lookup(params[:asin]).first
		description = raw_product.try(:editorial_reviews).try(:editorial_review).try(:content)
		if raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100 == 0
			offer_price = raw_product.item_attributes.try(:list_price).try(:amount).to_f/100
		else
			offer_price = raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100
		end
		@shipping_categories = Spree::ShippingCategory.all
		sku = raw_product.item_attributes.title[0..2].upcase+SecureRandom.hex(5).upcase
		asin_no = raw_product.asin
		@product = Spree::Product.where(asin: raw_product.asin,store_id: current_spree_user.stores.first.try(:id)).first
		if @product.blank?
			@product = Spree::Product.new({name: raw_product.item_attributes.title, description: description, sku: sku, price: offer_price ,  available_on: Time.zone.now.strftime("%Y/%m/%d"), shipping_category_id: Spree::ShippingCategory.find_by_name("Default").try(:id), image_url: raw_product.large_image.try(:url), asin: asin_no}) 
			raw_product.item_attributes.each do |amazon_products_properties|
				if amazon_products_properties[1].class.to_s == "REXMLUtiliyNodeString"
          property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
          product_property = @product.product_properties.build(value: amazon_products_properties[1])
          product_property.property = property  
        elsif amazon_products_properties[1].class.to_s == "Array"
          property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
          amazon_products_properties[1].each do |ap|
            product_property = @product.product_properties.build({value: ap})
            product_property.property = property
          end
        end
			end	
		else
			flash.now[:failure] = 'Could not be saved - this product is already exist!'
			redirect_to :back
		end
	end

	def create
		@product = Spree::Product.new(product_params)
		p @product.properties
		@product.attributes = product_params.merge({store_id: current_spree_user.stores.first.try(:id)})
		if @product.save
			image = @product.images.new({attachment: params[:product][:image_url]})
			image.save
			redirect_to edit_merchant_product_path(@product), notice: "Successfully created"
		else
			@shipping_categories = Spree::ShippingCategory.all
			render :new
		end
		# redirect_to :back
	end

	def import_collection
		if params[:product_ids].blank?
			 redirect_to :back, :params => @params , notice: "please Select Product created"
		else 
			AMAZON_CLIENT.lookup(params[:product_ids]).each do |raw_product|
				description = raw_product.try(:editorial_reviews).try(:editorial_review).try(:content)
				if raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100 == 0
					offer_price = raw_product.item_attributes.try(:list_price).try(:amount).to_f/100
				else
					offer_price = raw_product.try(:offer_summary).try(:lowest_new_price).try(:amount).to_f/100
				end
				image_u = raw_product.large_image.try(:url)
				sku = raw_product.item_attributes.title[0..2].upcase+SecureRandom.hex(5).upcase
				asin_no = raw_product.asin
				@product = Spree::Product.where(asin: raw_product.asin,store_id: current_spree_user.stores.first.try(:id)).first
				if @product.blank?
					@product = Spree::Product.create({name: raw_product.item_attributes.title,description: description, price: offer_price, available_on: Time.zone.now.strftime("%Y/%m/%d"), shipping_category_id: Spree::ShippingCategory.find_by_name("Default").try(:id), image_url: raw_product.large_image.try(:url),store_id: current_spree_user.stores.first.try(:id),asin:asin_no}) 
					raw_product.item_attributes.each do |amazon_products_properties|
						if amazon_products_properties[1].class.to_s == "REXMLUtiliyNodeString"
		          property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
		          product_property = @product.product_properties.build(value: amazon_products_properties[1])
		          product_property.property = property  
		        elsif amazon_products_properties[1].class.to_s == "Array"
		          property = Spree::Property.where(name: amazon_products_properties[0], presentation: amazon_products_properties[0].titleize).first_or_create
		          amazon_products_properties[1].each do |ap|
		            product_property = @product.product_properties.build({value: ap})
		            product_property.property = property
		          end
		        end
		        @product.save
					end
					image = @product.images.new(attachment: raw_product.large_image.url)
					image.save
				else
					redirect_to merchant_stores_path,  notice: "Product is already exist"
					return 	
				end
			end
			if @product.save
				redirect_to merchant_stores_path 
				return
			end 
		end

	end

	private

		def product_params
			params.require(:product).permit(:name, :sku, :price, :prototype_id, :available_on,:asin,:brand, :shipping_category_id, :image_url, :description , product_properties_attributes: [:value, :id, :property_id, :product_id, property_attributes: [:id, :name, :presentation]])
		end

end