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

			@eligible = (@order.line_items.sum(:quantity) - @order.customer_return_items.sum(:return_quantity)) == 0 ? false : true
		end

		def return_multiple_item
			p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
			p params
			if params[:customer_return_items].blank?
				redirect_to :back, :params => @params , notice: "please Select Item to be returned"
				return
			else
				params[:customer_return_items].each do |return_item|
					p "_______________________________________"
					p return_item["quantity"]
					p return_item["line_item_id"]
					p return_item["quantity"].present?
					p return_item["quantity"].nil?

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
									redirect_to :back, :params => @params , notice: "Quantity Can not be greater than Remaining Qty"
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

					# redirect_to order_customer_return_items_path(@order), notice: 'Your Request is Registered'
				 # 	return
				# 	qty = return_item["quantity"].first.to_i
				# 	line_item = return_item["line_item_id"].to_i
				# 	p return_item
				# 	p return_item["line_item_id"].to_i
				# 	p return_item["quantity"].first.to_i

				# 	@customer_return_item = Spree::CustomerReturnItem.new(order_id: @order.id, line_item_id: line_item, refunded: 'requested', status: 'requested', return_quantity: qty)
				# 	unless @customer_return_item.save
				# 		redirect_to order_customer_return_items_path(@order),  notice: 'Something went wrong'
				# 	end
				end
			end

			redirect_to order_customer_return_items_path(@order),  notice: 'Your request is register for return item(s)'
		end

		private 

		def find_order
			@order = Spree::Order.find_by_number(params[:order_id])
		end
	end
end
