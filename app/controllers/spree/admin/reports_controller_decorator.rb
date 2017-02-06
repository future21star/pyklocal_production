module Spree
	module Admin
		ReportsController.class_eval do 

			def initialize
				super 
				ReportsController.add_available_report!(:sales_total)
				ReportsController.add_available_report!(:products_sale_report)
				ReportsController.add_available_report!(:store_details_report)
			end

			def store_details_report
				per_page = 20
				p params[:page]
				unless params[:page].blank?
					# p params[:page]
					page = params[:page].to_i
					start = per_page * ( params[:page].to_i - 1)
				else
					start = 0
				end

				if params[:download_excel]
					@date1 = params[:order_completed_at_gt].to_date
					@date2 = params[:order_completed_at_lt].to_date
				elsif params[:order_completed_at_lt].present? && params[:order_completed_at_gt].present?
					@date1 = params[:order_completed_at_gt].to_date
					@date2 = params[:order_completed_at_lt].to_date
				else
					if params[:orders_completed_at_gt].blank? || params[:orders_completed_at_gt].values.first.blank? || params[:orders_completed_at_lt].first.blank?
						@date1 = 2.week.ago
						@date2 = Date.today
					elsif params[:orders_completed_at_gt].values.first.present? && params[:orders_completed_at_lt].first.blank?
						@date1 = params[:orders_completed_at_gt].values.first.to_date
						@date2 = Date.today
					else
						@date1 = params[:orders_completed_at_gt].values.first.to_date
						@date2 = params[:orders_completed_at_lt].first.to_date
						if @date1 > @date2
							redirect_to :back, notice: "From date can not be greater than To date. Displaying last 2 weeks records"
						end
					end
				end
				# p params[:orders_completed_at_lt].first.blank?
				# p params[:orders_completed_at_gt].values.first < params[:orders_completed_at_lt].first
				# p params[:orders_completed_at_lt].first
				# date1 = 2.week.ago
				# date2 = 1.week.ago
				# date1 = params[:orders_completed_at_gt].values.first.to_date
				# date2 = params[:orders_completed_at_lt].first.to_date
				params[:q] = {} unless params[:q]
				if params[:q][:orders_completed_at_gt].blank?
					params[:q][:orders_completed_at_gt] = Time.zone.now.beginning_of_month
				else
					params[:q][:orders_completed_at_gt] = Time.zone.parse(params[:q][:orders_completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
				end

				if params[:q] && !params[:q][:orders_completed_at_lt].blank?
					params[:q][:orders_completed_at_lt] = Time.zone.parse(params[:q][:orders_completed_at_lt]).end_of_day rescue ""
				end

				params[:q][:s] ||= "orders_completed_at desc"

				# @search = Merchant::Store.includes(:orders).ransack(params[:q])
				@store_sale_array = []
				if params[:download_excel]
					Merchant::Store.all.each do |merchant|
						Hash merchant_hash = Hash.new
						merchant_hash["id".to_sym] = merchant.id
						merchant_hash["name".to_sym] = merchant.name
						merchant_hash["sales_amount".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).collect{|obj| obj.price * obj.quantity}.sum.to_f.round(2)

						merchant_hash["tax".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).select("spree_line_items.quantity,spree_line_items.price,spree_line_items.tax_category_id").collect{|x| Spree::TaxCategory.find(x.tax_category_id).tax_rates.first.amount * x.price * x.quantity}.sum.to_f.round(2)

						merchant_hash["amount_return".to_sym] = Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ?",@date1,@date2, merchant.id).sum(:item_return_amount).to_f.round(2)

						merchant_hash["tax_return".to_sym] = Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ?",@date1,@date2, merchant.id).sum(:tax_amount).to_f.round(2)						
						@store_sale_array.push(merchant_hash)
					end
				else
					Merchant::Store.all.offset(start).limit(per_page).each do |merchant|
						Hash merchant_hash = Hash.new
						merchant_hash["id".to_sym] = merchant.id
						merchant_hash["name".to_sym] = merchant.name
						merchant_hash["sales_amount".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).collect{|obj| obj.price * obj.quantity}.sum.to_f.round(2)

						merchant_hash["tax".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).select("spree_line_items.quantity,spree_line_items.price,spree_line_items.tax_category_id").collect{|x| Spree::TaxCategory.find(x.tax_category_id).tax_rates.first.amount * x.price * x.quantity}.sum.to_f.round(2)

						merchant_hash["amount_return".to_sym] = Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ?",@date1,@date2, merchant.id).sum(:item_return_amount).to_f.round(2)

						merchant_hash["tax_return".to_sym] = Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ?",@date1,@date2, merchant.id).sum(:tax_amount).to_f.round(2)			
						@store_sale_array.push(merchant_hash)
					end
				end

				@total_merchant_count = Merchant::Store.all.count / per_page
				if (Merchant::Store.all.count % per_page) != 0
					@total_merchant_count = @total_merchant_count + 1
				end

				if params[:download_excel] && eval(params[:download_excel])
					request.format = "xls"
					respond_to do |format|
						format.xls #{ send_file(file_name) }
					end
				end

			end

			def store_sale_product

				@date1 = params[:order_completed_at_gt].to_date
				@date2 = params[:order_completed_at_lt].to_date
				@store_id = params[:store_id]

				@sale_product =  Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (DATE(spree_line_items.updated_at) >= ? AND DATE(spree_line_items.updated_at) <= ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: @store_id}).select("spree_line_items.variant_id, spree_line_items.quantity").group("spree_line_items.variant_id").sum("spree_line_items.quantity")
				p @sale_product
				@product_sale_arr = []
				@return_item_arr = []
				 @sale_product.keys.each do |variant_id|
					variant = Spree::Variant.find(variant_id)
					Hash product_sale_hash = Hash.new
					product_sale_hash["name".to_sym] = variant.product.name
					product_sale_hash["price".to_sym] = variant.price.to_f.round(2)
					product_sale_hash["tax_rate".to_sym] = variant.tax_category_id.present? ? variant.tax_category.tax_rates.first.amount.to_f : variant.product.tax_category.tax_rates.first.amount.to_f 
					product_sale_hash["option_name".to_sym] = variant.option_name
					product_sale_hash["qty".to_sym] = @sale_product[variant_id]

					@product_sale_arr.push(product_sale_hash)
				 end
				
				@return_items =  Spree::CustomerReturnItem.where("DATE(updated_at) >= ? AND DATE(updated_at) <= ? AND store_id = ?",@date1,@date2, @store_id).group("customer_return_items.line_item_id").sum("customer_return_items.return_quantity")

				unless @return_items.blank?
					@return_items.keys.each do |return_item|
						p return_item
						Hash return_item_hash = Hash.new
						variant = Spree::LineItem.find(return_item).variant
						return_item_hash["name".to_sym] = variant.product.name
						return_item_hash["price".to_sym] = variant.price.to_f.round(2)
						return_item_hash["tax_rate".to_sym] = variant.tax_category_id.present? ? variant.tax_category.tax_rates.first.amount.to_f : variant.product.tax_category.tax_rates.first.amount.to_f 
						# return_item_hash["option_name".to_sym] = variant.option_name
						return_item_hash["qty".to_sym] = @return_items[return_item]

						 @return_item_arr.push(return_item_hash)
					end
				end
				p "((((((((((((((((((((((((((((((((((((((((((("
				p @return_item_arr
				render json: {
					product: @product_sale_arr.as_json(),
					return_items: @return_item_arr.as_json()
				}
			end

			def products_sale_report
				params[:q] = {} unless params[:q]
				if params[:q][:orders_completed_at_gt].blank?
					params[:q][:orders_completed_at_gt] = Time.zone.now.beginning_of_month
				else
					params[:q][:orders_completed_at_gt] = Time.zone.parse(params[:q][:orders_completed_at_gt]).beginning_of_day rescue Time.zone.now.beginning_of_month
				end

				if params[:q] && !params[:q][:orders_completed_at_lt].blank?
					params[:q][:orders_completed_at_lt] = Time.zone.parse(params[:q][:orders_completed_at_lt]).end_of_day rescue ""
				end

				params[:q][:s] ||= "orders_completed_at desc"
				
				@search = Spree::Product.ransack(params[:q])
				@products = @search.result(distinct: true).joins(:orders).where(spree_orders: {state: "complete"}).page(params[:page]).
					per(30)
				@merchant = Merchant::Store.all

				if params[:download_excel] && eval(params[:download_excel])
					request.format = "xls"
					respond_to do |format|
						format.xls #{ send_file(file_name) }
					end
				end
				
			end





			def download_csv_file_for_store
				report_download_csv_file(params[:q][:orders_completed_at_gt], params[:q][:orders_completed_at_lt])
			end

			def report_download_csv_file(start_date,end_date)
				start_date = Date.strptime(start_date, "%m/%d/%Y")
				end_date  =  Date.strptime(end_date, "%m/%d/%Y")

				header = 'Store Name, Total sales amount, Total sales tax , total discount earned by PYKLOCAL, Delivery charges adjustments , Total Net Pay to the store'
				file_name = "Store_order_details#{Date.today}.csv"
				File.open(file_name, "w") do |writer|
					writer << header
					writer << "\n"
					Merchant::Store.each do |merchant|
						merchant.orders.where("DATE(created_at) >= ? AND DATE(created_at) <= ? ", start_date, end_date).each do |order|
							csv_value = order.sum(:total), order.keyword, order.user.try(:email),order.presented_link, order.completetion_number, order.completion_callback,order.cashback.to_f,order.zip.to_i,order.created_at.strftime("%B-%d-%Y  %T")
								writer << csv_value.map(&:inspect).join(', ')
								writer << "\n"
						end
					end
				end             
					send_file(file_name)
					# NotifyUser.send_orders_csv_to_admin(file_name).deliver
			end  

		end
	end
end