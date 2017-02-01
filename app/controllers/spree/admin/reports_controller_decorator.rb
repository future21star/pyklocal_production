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
        # p "********************************************"
        # p params[:orders_completed_at_gt]
        # p params[:orders_completed_at_gt]["2017/01/01"]
        p params[:orders_completed_at_gt]
        p params[:range]
        # p params[:orders_completed_at_gt].values
        # p params[:orders_completed_at_lt].first.to_date
        p "*********8888**************************"
        if params[:download_excel]
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
        Merchant::Store.all.each do |merchant|
          Hash merchant_hash = Hash.new
          merchant_hash["id".to_sym] = merchant.id
          merchant_hash["name".to_sym] = merchant.name
          merchant_hash["sales_amount".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (spree_line_items.updated_at > ? AND spree_line_items.updated_at < ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).sum(:pre_tax_amount).to_f.round(2)

          merchant_hash["tax".to_sym] = Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (spree_line_items.created_at > ? AND spree_line_items.created_at < ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: merchant.id}).sum(:additional_tax_total).to_f.round(2)
          @store_sale_array.push(merchant_hash)
        end
        # @search = Spree::LineItem.ransack(params[:q])
        # p "8888888888888888"
        # p @search
        # @merchant = Merchant::Store.includes(:orders)

        p "*************************************"
        p @date1
        p @date2
        p @store_sale_array
        # p @store_sale_array.first
        # p @store_sale_array.first[:name]

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

        @sale_product =  Spree::LineItem.where("(delivery_state = ? OR delivery_type = ?) AND (spree_line_items.updated_at > ? AND spree_line_items.updated_at < ?)","delivered","pickup",@date1,@date2).joins(:product).where(spree_products:{store_id: @store_id}).select("spree_line_items.variant_id, spree_line_items.quantity").group("spree_line_items.variant_id").sum("spree_line_items.quantity")
        @product_sale_arr = []
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
        
        render json: @product_sale_arr.as_json
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