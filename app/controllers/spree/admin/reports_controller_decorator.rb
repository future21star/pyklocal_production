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

        @search = Merchant::Store.includes(:orders).ransack(params[:q])
        @merchant = Merchant::Store.includes(:orders)

        if params[:download_excel] && eval(params[:download_excel])
          request.format = "xls"
          respond_to do |format|
            format.xls #{ send_file(file_name) }
          end
        end

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