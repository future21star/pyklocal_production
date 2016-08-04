module Spree
  module Admin
    ReportsController.class_eval do 

      def initialize
        super 
        ReportsController.add_available_report!(:sales_total)
        ReportsController.add_available_report!(:products_sale_report)
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

        if params[:q] && !params[:q][:sell_count_gt].blank?
          params[:q][:sell_count_gt] = "sell_count desc"
        end

        params[:q][:s] ||= "orders_completed_at desc"
        
        @search = Spree::Product.ransack(params[:q])
        @products = @search.result(distinct: true).joins(:orders)
        @merchant = Merchant::Store.all
      end

    end
  end
end