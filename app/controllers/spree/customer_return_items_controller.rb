module Spree
	class CustomerReturnItemsController < Spree::StoreController

		before_action :find_order

		def index
			@customer_return_items = Spree::CustomerReturnItem.where(order_id: @order.id)
		end

		def new
			@customer_return_item = Spree::CustomerReturnItem.new
		end

		def create
			p "*************************************"
			p params 
		end

		def destroy
			@customer_return_item = Spree::CustomerReturnItem.find(params[:id])
			if @customer_return_item.delete
				redirect_to :back, :params => @params , notice: "Item Deleted Succssfully"
				return
			else
				redirect_to :back, :params => @params , notice: "Something went wrong"
				return
			end
		end

		def edit
		end

		def eligible_item
			p "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
			p params
			if @order.state =='canceled'
				redirect_to spree.orders_path , notice: "Cancel order can not be return"
				return
			elsif (@order.completed_at.to_date + 14.days) < Date.today
				redirect_to spree.orders_path , notice: "Order can only be return within the 14 days of order delivered"
				return
			elsif @order.is_undelivered?
				redirect_to spree.orders_path , notice: "You can return item(s) only after complete order is delivered"
				return
			else
				@eligible = (@order.line_items.sum(:quantity) - @order.customer_return_items.sum(:return_quantity)) == 0 ? false : true
				return
			end
		end

		def return_multiple_item
				p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
				p params
			if @order.state == 'canceled'
				redirect_to spree.orders_path, notice: "Canceled order can not be return"
				return
			else
				if params[:customer_return_items].blank?
					redirect_to :back, :params => @params , notice: "please Select Item to be returned"
					return
				else
					params[:customer_return_items].each do |return_item|
						if return_item["line_item_id"].present? && return_item["quantity"].present?
							if return_item["quantity"].first.blank?
								redirect_to :back, :params => @params , notice: "Quantity can not be blank"
								return
							else
								qty = return_item["quantity"].first.to_i
								line_item = return_item["line_item_id"].to_i
								remaining_qty = Spree::LineItem.find(line_item).quantity - Spree::LineItem.find(line_item).return_quantity(@order)
								p "Lllllllllllllllllllllllllll"
								p remaining_qty
									if qty > remaining_qty  
										redirect_to :back, :params => @params , notice: "Quantity can not be greater than remaining Qty"
										return
									else
										@customer_return_item = Spree::CustomerReturnItem.new(order_id: @order.id, line_item_id: line_item, refunded: 'Requested', status: 'Requested', return_quantity: qty)
										unless @customer_return_item.save
											redirect_to order_customer_return_items_path(@order),  notice: 'Something went wrong'
											return
										# else
										# 	# redirect_to order_customer_return_items_path(@order),  notice: 'Your Request is Registered'
										# 	redirect_to order_customer_return_items_path(@order), notice: 'Your Request is Registered'
										# 	return
										end
									end
							end
						else
							redirect_to :back, :params => @params , notice: "Please Provide Quantity"
							return
						end
					end
				end

				redirect_to order_customer_return_items_path(@order),  notice: 'Your request is registered for return item(s)'
			end
		end

		private 

		def find_order
			@order = Spree::Order.find_by_number(params[:order_id])
		end
	end
end
