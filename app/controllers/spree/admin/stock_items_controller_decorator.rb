module Spree
	module Admin
		StockItemsController.class_eval  do
			

      def create
        unless params[:stock_movement][:quantity].include?('.')
          if params[:stock_movement][:quantity].to_i > 0
            variant = Variant.find(params[:variant_id])
            stock_location = StockLocation.find(params[:stock_location_id])
            stock_movement = stock_location.stock_movements.build(stock_movement_params)
            stock_movement.stock_item = stock_location.set_up_stock_item(variant)

            if stock_movement.save
            	Sunspot.index(variant.product)
              Sunspot.commit
              flash[:success] = flash_message_for(stock_movement, :successfully_created)
            else
              flash[:error] = Spree.t(:could_not_create_stock_movement)
            end
          else
            flash[:error] = "Quantity must be greater than 0 (zero)"
          end
        else
            flash[:error] = "Quantity must be a whole number"
        end

        redirect_to :back
      end
		end
	end
end