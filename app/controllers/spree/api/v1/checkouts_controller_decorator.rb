module Spree
	Api::V1::CheckoutsController.class_eval do
		
	    def next
	    	begin
	    		p "7777777779999999999999999999999999999999999999999999999999"
	    		p params[:order_state]
		    	if @order.state == params[:order_state]
				      authorize! :update, @order, order_token
				    if  @order.state != "confirm"
				  		if params[:order][:bill_address_attributes].present?
				  			@order.bill_address.update_attributes(params[:order][:bill_address_attributes])
				  		end
				  		if params[:order][:ship_address_attributes].present?
				  			@order.ship_address.update_attributes(params[:order][:ship_address_attributes])
				  		end
				  	end
				      @order.next!
				      render json: {
				      	status: "1",
				      	message: "Detail Fetch succesfully",
				      	shipment_minimum_price: FREE_DELIVERY_ORDER_PRICE.to_s,
				      	order_detail: to_stringify_checkout_json(@order, [])
				      }
				  else
				  	p @order.state
				  	if  @order.state != "confirm"
				  		p "222222222"
				  		if params[:order][:bill_address_attributes].present?
				  			p "1111111"
				  			@order.bill_address.update_attributes(params[:order][:bill_address_attributes])
				  		end
				  		if params[:order][:ship_address_attributes].present?
				  			p "333333"
				  			@order.ship_address.update_attributes(params[:order][:ship_address_attributes])
				  		end
				  	end
				  	render json: {
				      status: "1",
				      message: "Detail Fetch succesfully without going to next state",
				      shipment_minimum_price: FREE_DELIVERY_ORDER_PRICE.to_s,
				      order_detail: to_stringify_checkout_json(@order, [])
				    }
				  end
		    rescue Exception => e
		      render json: {
		      	status: "0",
		      	message: "could not transist",
		      	error: e.message.to_s
		      }
		    end
	    end

	      def update
	      	begin
		      	p params[:order_state]
		      	# if @order.state == params[:order_state]
	         	  authorize! :update, @order, order_token
	          	  if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
		            if current_api_user.has_spree_role?('admin') && user_id.present?
		              @order.associate_user!(Spree.user_class.find(user_id))
		            end

		            return if after_update_attributes

		            if @order.state == params[:order_state]
			            if @order.completed? || @order.next
			                state_callback(:after)
			              render json: {
				      				status: "1",
				      				message: "Detail Fetch ashajshjasuccesfully",
				      				shipment_minimum_price: FREE_DELIVERY_ORDER_PRICE.to_s,
				      				order_detail: to_stringify_checkout_json(@order, [])
				      		  }
			            else
			              respond_with(@order, default_template: 'spree/api/v1/orders/could_not_transition', status: 422)
			            end
			          else
			          	render json: {
			      				status: "1",
			      				message: "Detail Fetch succesfully after skipping next",
			      				shipment_minimum_price: FREE_DELIVERY_ORDER_PRICE.to_s,
			      				order_detail: to_stringify_checkout_json(@order, [])
			      		  }
			          end
		          else
		            invalid_resource!(@order)
		          end
		      #   else
		      #   	if  @order.state != "confirm"
				  		# 	p "222222222"
					  	# 	if params[:order][:bill_address_attributes].present?
					  	# 		p "1111111"
					  	# 		@order.bill_address.update_attributes(params[:order][:bill_address_attributes])
					  	# 	end
					  	# 	if params[:order][:ship_address_attributes].present?
					  	# 		p "333333"
					  	# 		@order.ship_address.update_attributes(params[:order][:ship_address_attributes])
					  	# 	end
					  	# end
	       #  	  render json: {
		      # 				status: "1",
		      # 				message: "Detail Fetch succesfully without going to next state",
			     #  			shipment_minimum_price: FREE_DELIVERY_ORDER_PRICE.to_s,
		      # 				order_detail: to_stringify_checkout_json(@order, [])
		      # 		}
		      #   end
		      rescue Exception => e
		      	render json: {
			      	status: "0",
			      	message: "could not transist",
			      	error: e.message.to_s
		      	}
		      end
        end


	    private 



	   	 
	end
end