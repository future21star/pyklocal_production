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
	end

	def new
		raw_product = AMAZON_CLIENT.lookup(params[:asin]).first
		@shipping_categories = Spree::ShippingCategory.all
		sku = raw_product.item_attributes.title[0..2].upcase+SecureRandom.hex(5).upcase
		@product = Spree::Product.new({name: raw_product.item_attributes.title, sku: sku, price: raw_product.item_attributes.list_price.try(:amount).to_f/100, available_on: Time.zone.now.strftime("%Y/%m/%d"), shipping_category_id: Spree::ShippingCategory.find_by_name("Default").try(:id), image_url: raw_product.large_image.try(:url)}) 
	end

	def create
		
		@product = Spree::Product.new(product_params)
		@product.attributes = product_params.merge({store_id: current_spree_user.stores.first.try(:id)})
		if @product.save
			image = @product.images.new({attachment: params[:product][:image_url]})
			image.save
			redirect_to edit_merchant_product_path(@product), notice: "Successfully created"
		else
			@shipping_categories = Spree::ShippingCategory.all
			render :new
		end
	end

	private

		def product_params
			params.require(:product).permit(:name, :sku, :price, :available_on, :shipping_category_id, :image_url)
		end

end