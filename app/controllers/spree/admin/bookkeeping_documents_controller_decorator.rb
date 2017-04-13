module Spree
	module Admin
		BookkeepingDocumentsController.class_eval  do


      def index
        # Massaging the params for the index view like Spree::Admin::Orders#index
        params[:q] ||= {}
        params[:q][:s] ||= "created_at desc"
        @search = Spree::BookkeepingDocument.ransack(params[:q])
        @bookkeeping_documents = @search.result
        @bookkeeping_documents = @bookkeeping_documents.where(printable: @order) if order_focused?
        @bookkeeping_documents = @bookkeeping_documents.page(params[:page] || 1).per(10)
      end

		end
	end
end