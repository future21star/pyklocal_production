module Spree
	Api::V1::OrdersController.class_eval do 

		include Spree::Api::ApiHelpers
		include Spree::Core::ControllerHelpers::Order

		before_action :load_order, only: [:show, :cancel, :refresh_order_summary, :cancel_coupon, :cancel_coupon_code, :get_adjustments]
		before_action :find_store, only: [:show]
		before_action :find_driver, only: [:index, :show]
		skip_before_filter :authenticate_user, only: [:apply_coupon_code, :refresh_order_summary, :cancel_coupon]
		before_action :find_user, only: [:cancel, :update, :create]

		def index
			@orders_list = []
			params[:lat] = @user.api_tokens.last.try(:latitude)
			params[:lng] = @user.api_tokens.last.try(:longitude)
			if params[:lat] && params[:lng]
				@search = Sunspot.search(Merchant::Store) do
					order_by_geodist(:loctn, params[:lat], params[:lng])
				end
				@stores = @search.results
				unless @stores.blank?
					@stores.each do |store|
						unless store.pickable_store_orders.blank?
							store.pickable_store_orders.each do |s_o|
								p "9999999999999999999999999999"
								p s_o 
								if s_o.present? && s_o.state != 'canceled'
									line_items = s_o.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: store.id})
									line_item_ids = line_items.collect(&:id)
									@orders_list.push({order_number: s_o.number, store_name: store.name, line_item_ids: line_item_ids, state: line_items.collect(&:delivery_state).uniq.join, location: {lat: store.try(:latitude), long: store.try(:longitude)}})
								end
							end						
						end
					end
				end
				render json: {
					status: 1,
					details: @orders_list.as_json()
				}
			else
				render json:{
					status: 0,
					message: "Location not found. Turn on your location services."
				}
			end
		# rescue Exception => e
		# 	api_exception_handler(e)
		# ensure
		# 	render json: @orders_list.as_json()
		end

		def create
			begin
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				p "--------------------------------------adding product to cart--------------------------------------"				
				unless Spree::Variant.exists?((params[:order][:line_items]).first.values.last)
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					p "------------------------------------------product is no longer available-------------------------------------"
					render json:{
						status: "0",
						message: "Product is no longer available"
					}
					return
				end
				variant  = Spree::Variant.find((params[:order][:line_items]).first.values.last)
				if (variant.product.visible == false)  || (variant.product.buyable == false)
					render json:{
						status: "0",
						message: "Product is no longer available"
					}
					return
				end
			  authorize! :create, Order
			  order_user = if @current_user_roles.include?('admin') && order_params[:user_id]
			    Spree.user_class.find(order_params[:user_id])
			  elsif params[:user_id]
			    Spree::user_class.find(params[:user_id])
			  else
			    current_api_user
			  end
			  import_params = if @current_user_roles.include?("admin")
			    params[:order].present? ? params[:order].permit! : {}
			  else
			    order_params
			  end
			  @in_wishlist_variant = @user.wishlists.where(variant_id: params[:order][:line_items_attributes].first["variant_id"])
			  unless @in_wishlist_variant.blank?
			  	@in_wishlist_variant.delete_all
			  end
			  @incomplete_order = @user.orders.where("state != ? AND state != ? AND state != ?", "complete", "canceled", "returned").last
			  if @incomplete_order.blank?
			 		@order = Spree::Core::Importer::Order.import(order_user, import_params)
			 		@order.update_attributes(bill_address_id: nil)
			 		@order.update_attributes(ship_address_id: nil)
			 		render json: {
	      				status: "1",
	      				cart_count: order_user.cart_count.to_s,
	      				message: "product added successfully"
	      				# order_detail: to_stringify_checkout_json(@order, [])
	      		}
			 	else
			 		params[:order][:line_items_attributes].each do |line_item|
			 			variant = Spree::Variant.find(line_item["variant_id"])
			 			quantity = line_item["quantity"].to_i
			 			delivery_type = line_item["delivery_type"] || "home_delivery"
			 			already_ordered_quantity = @incomplete_order.line_items.select{|line_item| line_item.variant_id == variant.id.to_i }.try(:first).try(:quantity)
			 			if already_ordered_quantity.nil? || (variant.total_on_hand >= (already_ordered_quantity.to_i + quantity))
	          	@incomplete_order.contents.add(variant, quantity, {}, delivery_type)
	          	if line_item["in_wishlist"] == "true"
	          		@user.wishlists.where(variant_id: line_item["variant_id"]).delete_all
	          	end
	          	 render json: {
	      				status: "1",
	      				cart_count: order_user.cart_count.to_s,
	      				message: "product added successfully"
	      				# order_detail: to_stringify_checkout_json(@incomplete_order, [])
	      			}
	      		else
	      			render json:{
	      				status: "0",
	      				message: "You already have this item in your cart. Max Quantity Available to add: " + (variant.total_on_hand - already_ordered_quantity).to_s
	      			}
	          end
          end
			 	end
			rescue Exception => e
				render json: {
					status: 0,
					message: e.message
				}		  	
		  end
		end    


		def update
      find_order(true)
      authorize! :update, @order, order_token
      Hash line_items_attributes_hash = Hash.new
      params_counter = 0
      p "************************************************************************************"
      p order_params
      params[:order][:line_items_attributes].each do |line_item|
      	p "___________________________________________________________________________________"
      	line_items_attributes_hash[params_counter.to_s] = line_item
      	params_counter = params_counter +1
      	p line_item
      end
      p line_items_attributes_hash
      Hash order_params_hash = Hash.new
      order_params_hash["line_items_attributes"] = line_items_attributes_hash
      p order_params_hash
      order_params_hash = order_params_hash
      if @order.contents.update_cart(order_params)
        user_id = params[:order][:user_id]
        p user_id
        if current_api_user.has_spree_role?('admin') && user_id
          @order.associate_user!(Spree.user_class.find(user_id))
        end
        #respond_with(@order, default_template: :show)
        unless @order.line_item_ids.blank?
          render json:{
          	status: "1",
          	message: "Updated Successfully",
          	cart_count: @order.user.cart_count.to_s,
          	order_number: @order.number.to_s,
						order_token: @order.guest_token.to_s,
						order_state: @order.state.to_s,
          	details: to_stringify_variant_json(@order, @user, [])
          }
        else
        	render json:{
        		status: "0",
        		message: "Cart is empty"
        	}
        end
      else
        #invalid_resource!(@order)
        render json:{
        	status: "0",
        	message: @order.errors.full_messages.join(', ')
        }
      end
    end

		def show
			# @user = Spree::ApiToken.where(token: params[:token]).try(:first).try(:user)
			line_items = @order.line_items.joins(:product).where(spree_line_items: {delivery_type: "home_delivery"}, spree_products: {store_id: @store.id})
			pick_up_and_delivery = {
																store_address: @store.address, 
																store_zipcode: @store.zipcode, 
																buyer_name: @order.buyer_name, 
																buyer_address: @order.delivery_address, 
																buyer_zipcode: @order.buyer_zipcode, 
																lat_long: @store.location
															}
		rescue Exception => e
			api_exception_handler(e)
		ensure
			render json: {
				product_details: line_items.as_json({
					only: [:id, :price, :quantity], 
					methods: [:product_name]
				}),
				state: line_items.collect(&:delivery_state).uniq.join,
				pick_up_and_delivery: pick_up_and_delivery
			}
		end

		def cancel
			if @order.is_any_item_shipped? == true
				render json:{
					status: "0",
					message: "Order can not be cancelled beacuse item(s) are already shipped"
				}
      elsif (@order.completed_at.to_date + 14.days) < Date.today 
      	render json:{
					status: "0",
					message: "Order can only be cancel within 14 days"
				}
      else
        if @order.order_seller.any?
          @order.order_seller.each do |email|
            UserMailer.notify_seller_cancel_order(@order,email).deliver
          end
        end
        @order.update_attributes(state: "canceled")
        render json:{
					status: "0",
					message: "Order cancellation process has been initiated!"
				}
      #respond_with(@order, default_template: :show)
      end
  	end

	def apply_coupon_code
      find_order
      authorize! :update, @order, order_token
      if @order.adjustments.blank?
	      if params[:coupon_code]
		      @order.coupon_code = params[:coupon_code]
		      @handler = PromotionHandler::Coupon.new(@order).apply
		      @order = Spree::Order.find(@order.id)
		      render json: {
		      	status: @handler.successful? ? "1" : "0" ,
		      	message: @handler.successful? ? "Coupon code successfully applied" : @handler.error.to_s,
		      	details: get_order_adjustments(@order)
		      }
		    else
		    	render json:{
		    		status: "0",
		    		message: "Please enter a coupon code"
		    	}
		    end
		  else
		  	render json:{
		  		status: "0",
		  		message: "Two coupon can not be applied to order together"
		  	}
		  end
		  # render json:{
		  # 	detail: get_order_adjustments(@order)
		  # }
   end

   def get_adjustments
   	render json: {
   		detail: get_order_adjustments(@order)
   	}
   end

    def cancel_coupon
    	@order.adjustments.delete_all
    	@order.promotions.destroy
    	Spree::OrderPromotion.where(order_id: @order.id).delete_all
    	@order.update_totals
			@order.persist_totals
    	redirect_to :back
    end

    def cancel_coupon_code
    	unless @order.state == 'complete'
	    	@order.adjustments.delete_all
	    	@order.promotions.destroy
	    	Spree::OrderPromotion.where(order_id: @order.id).delete_all
	    	@order.update_totals
				@order.persist_totals
	    	@order = Spree::Order.find(@order.id)
	    	render json:{
	    		status: "1",
	    		message: "coupon code remove Successfully",
	    		details: get_order_adjustments(@order)
	    	}
	    else
	    	render json:{
	    		status: "0",
	    		message: "Order is complete , coupon can not be applied"
	    	}
	    end
    end

    def refresh_order_summary
    end

		private

		def order_params
        if params[:order]
          normalize_params
          params.require(:order).permit(permitted_order_attributes)
        else
          {}
        end
    	end

    	

    	def add_cart
        if params[:order]
          params.require(:order).permit(:variant_id , :quantity)
        else
          {}
        end
       end

      def normalize_params
        params[:order][:payments_attributes] = params[:order].delete(:payments) if params[:order][:payments]
        params[:order][:shipments_attributes] = params[:order].delete(:shipments) if params[:order][:shipments]
        params[:order][:line_items_attributes] = params[:order].delete(:line_items) if params[:order][:line_items]
        params[:order][:ship_address_attributes] = params[:order].delete(:ship_address) if params[:order][:ship_address]
        params[:order][:bill_address_attributes] = params[:order].delete(:bill_address) if params[:order][:bill_address]
      end

			def load_order
				id = params[:id] || params[:order_id]
				@order = Spree::Order.find_by_number(id)
			end

			def find_store
				@store = Merchant::Store.find_by_name(params[:store_name])
				render json: {status: 0, message: "Store not found, invalid store name"} unless @store.present?
			end 

			def find_driver
				@user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
				render json: {status: 0, message: "Driver not found"} unless @user.present?
			end

			def find_user
				@user = Spree::ApiToken.where(token: params[:token]).first.try(:user)
			end

	end
end