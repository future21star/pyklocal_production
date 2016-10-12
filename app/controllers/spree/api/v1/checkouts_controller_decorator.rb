module Spree
	Api::V1::CheckoutsController.class_eval do
		
	    def next
	      authorize! :update, @order, order_token
	      @order.next!
	      render json: {
	      	status: "1",
	      	order_detail: to_stringify_checkout_json(@order, [])
	      }
	    rescue Exception => e
	      render json: {
	      	status: "0",
	      	message: "could not transist",
	      	error: e.message.to_s
	      }
	    end

	      def update
          authorize! :update, @order, order_token

          if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
            if current_api_user.has_spree_role?('admin') && user_id.present?
              @order.associate_user!(Spree.user_class.find(user_id))
            end

            return if after_update_attributes

            if @order.completed? || @order.next
              state_callback(:after)
              render json: {
	      				status: "1",
	      				order_detail: to_stringify_checkout_json(@order, [])
	      		}
            else
              respond_with(@order, default_template: 'spree/api/v1/orders/could_not_transition', status: 422)
            end
          else
            invalid_resource!(@order)
          end
        end


	    private 



	   	 
	end
end