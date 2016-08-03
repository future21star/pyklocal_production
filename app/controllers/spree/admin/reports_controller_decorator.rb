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
        @search = Spree::Product.joins(:orders).ransack(params[:q])
        @products = @search.result
        @merchant = Merchant::Store.all
      end

    end
  end
end