module Spree
	Api::V1::LineItemsController.class_eval do 

		def create
			variant = Spree::Variant.find(params[:line_item][:variant_id])
      @line_item = order.contents.add(variant,params[:line_item][:quantity] || 1,line_item_params[:options] || {})

      if @line_item.errors.empty?
           # respond_with(@line_item, status: 201, default_template: :show)
	      render json: {
	        status: "1",
	        message: "Line Item add successfully"
	      }
      else
        render json:{
        	status: "0",
        	error: @line_item.errors.full_messages.join(", ")
        }
      end
		end

	end
end