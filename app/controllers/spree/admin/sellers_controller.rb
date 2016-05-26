module Spree
	class Admin::SellersController < Admin::ResourceController

		def index
			respond_with(@collection) do |format|
        format.html
        format.json { render :json => json_data }
      end
		end

		protected

			def collection
        return @collection if @collection.present?
        @collection = Spree::Role.find_by_name("merchant").try(:users)
        if request.xhr? && params[:q].present?
          @collection = @collection
                            .where("spree_users.email #{LIKE} :search
                            			 OR (spree_users.first_name #{LIKE} :search)
                            			 OR (spree_users.last_name #{LIKE} :search)",
                                  { :search => "#{params[:q].strip}%" })
                            .limit(params[:limit] || 100)
        else
          @search = @collection.ransack(params[:q])
          @collection = @search.result.page(params[:page]).per(Spree::Config[:admin_products_per_page])
        end
      end

	end
end