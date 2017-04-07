module Spree
	Api::V1::LineItemsController.class_eval do 

		attr_accessor :in_wishlist

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

		def destroy
			begin
	      @line_item = find_line_item
	      @order.contents.remove_line_item(@line_item)
	      render json:{
	      	status: "1",
	      	cart_count: order.user.cart_count.to_s,
	      	message: "Line item deleted successfully"
	      }
	    rescue Exception => e
	    	render json:{
	    		status: "0",
	    		cart_count: order.user.cart_count.to_s,
	    		message: e.message
	    	}
	    end
    end


    def update
    	begin
	      @line_item = find_line_item
	      if @order.contents.update_cart(line_items_attributes)
	        @line_item.reload
	        render json:{
	        	status: "1",
	        	cart_count: order.user.cart_count.to_s,
	        	message: "Line item updated successfully"
	        }
	      else
	        #invalid_resource!(@line_item)
	        render json:{
	        	status: "0",
	        	cart_count: order.user.cart_count.to_s,
	        	message: "Something went wrong"
	        }
	      end
	    rescue Exception => e
	    	render json:{
        	status: "0",
        	message: e.message
	      }
	    end
    end

    private
    	def line_items_attributes
	      {line_items_attributes: {
	          id: params[:id],
	          quantity: params[:line_item][:quantity],
	          options: line_item_params[:options] || {},
	          delivery_type:  params[:line_item][:delivery_type]
	      }}
   		end

   		def find_line_item
        id = params[:id].to_i
        order.line_items.detect { |line_item| line_item.id == id } or
            raise "Line Item does not exist"
      end
	end
end