module Spree
	class Api::V1::CustomerReturnItemsController < Spree::Api::BaseController

		before_action :find_order

		def index
			@customer_return_items = Spree::CustomerReturnItem.where(order_id: @order.id)
			unless @customer_return_items.blank?
				render json:{
					status: "1",
					order_number: @order.number.to_s,
					detail: to_stringify_customer_return_json(@customer_return_items, [])
				}
			else
				render json:{
					status: "0",
					order_number: @order.number.to_s,
					detail: "No return found"
				}
			end
		end

		def create
			if @order.state == 'canceled'
				render json:{
					status: "0",
					message: "Canceled order can not be return"
				}
				return
			else
				if params[:return_items].blank?
					render json:{
						status: "0",
						message: "No item was selected for return"
					}
					return
				else
					params[:return_items].each do |return_item|
						if return_item["line_item_id"].present? && return_item["quantity"].present?
							qty = return_item["quantity"].first.to_i
							line_item = return_item["line_item_id"].to_i
							remaining_qty = Spree::LineItem.find(line_item).quantity - Spree::LineItem.find(line_item).return_quantity(@order) 
							# p remaining_qty
								if qty > remaining_qty  
									render json:{
										status: "0",
										message: "Quantity can not be greater than remaining quantity"
									}
									return
								else
									@customer_return_item = Spree::CustomerReturnItem.new(order_id: @order.id, line_item_id: line_item, refunded: 'Requested', status: 'Requested', return_quantity: qty)
									unless @customer_return_item.save
										render json:{
											status: "0",
											message: 'Something went wrong'
										}
										return
									end
								end
						else
							render json:{
								status: "0",
								message: "Either Line item or quantity missing"
							}
							return
						end
					end
				end

				render json:{
					status: "1",
					message: "request successfully registered"
				}
			end
		end

		def destroy
			begin
				if Spree::CustomerReturnItem.exists?(params[:id])
			 	@return_item = Spree::CustomerReturnItem.find(params[:id])
			 	if @return_item.delete
			 		render json:{
			 			status: "1",
			 			message: "Item deleted successfully"
			 		}
			 	else
			 		render json:{
			 			status: "0",
			 			message: "Something went wrong while deleting the item"
			 		}
			 	end
			 else
			 	render json:{
			 		status: "0",
			 		message: "Item does not exist with given id"
			 	}
			 end
			rescue Exception => e
				render json:{
					status: "0",
					message: e.message.to_s
				}
			end
			 
		end

		def eligible_item
			begin
				if @order.state == 'canceled'
					render json:{
						status: "0",
						message: "Cancel order can not be return"
					}
				elsif (@order.completed_at.to_date + 14.days) < Date.today
					render json:{
						status: "0",
						message: "Order can only be return within the 7 days of order delivered"
					}
				elsif @order.is_undelivered?
					render json:{
						status: "0",
						message: "You can return item(s) only after complete order is delivered"
					}
				else
					if @order.line_items.sum(:quantity) - @order.customer_return_items.sum(:return_quantity) == 0
						render json:{
							status: "0",
							message: "You have already returned all the item of this Order"
						}
					else
						render json:{
							status: "1",
							message: "Item fetched successfully",
							detail: to_stringify_customer_returnable_item_json([])
						}
					end
				end
			rescue Exception => e
				render json:{
					status: "0",
					message: e.message.to_s
				}
			end
		end

		private

		def find_order
			@order =  Spree::Order.find_by_number(params[:order_number])
		end

		def to_stringify_customer_return_json c_obj , values = []
			c_obj.each do |obj|
				Hash return_item = Hash.new
				obj.attributes.each do |k,v|
					return_item[k.to_sym]  = v.to_s
					if k == "line_item_id"
						@line_item = Spree::LineItem.find(v)
						return_item["product_name".to_sym] = @line_item.variant.product.name.to_s
						unless @line_item.variant.product_images.blank?
							return_item["images".to_sym] = @line_item.variant.product_images
						else
							return_item["images".to_sym] = @line_item.variant.product.product_images
						end
					end
				end
				return_item["tax_rate".to_sym] = obj.line_item.variant.tax_category_id.present? ? (obj.line_item.variant.tax_category.tax_rates.first.amount.to_f * 100).to_s : (obj.line_item.product.tax_category.tax_rates.first.amount.to_f * 100).to_s 
				return_item["item_unit_price".to_sym] = obj.line_item.variant.price.to_f.round(2).to_s
				values.push(return_item)
			end
			return values
		end

		def to_stringify_customer_returnable_item_json values = []
			return_item_arr = []
			@order.line_items.each do |item|
				if item.quantity - item.return_quantity(@order) != 0
					Hash return_item_hash = Hash.new
					return_item_hash["line_item_id".to_sym] = item.id.to_s
					return_item_hash["product_name".to_sym] = item.variant.product.name.to_s
					return_item_hash["quantity".to_sym] = item.quantity.to_s
					return_item_hash["return_quantity".to_sym] = item.return_quantity(@order).to_s
					return_item_hash["remaining_quantity".to_sym] = (item.quantity - item.return_quantity(@order)).to_s
					unless item.variant.product_images.blank?
						return_item_hash["images".to_sym] = item.variant.product_images
					else
						return_item[_hash"images".to_sym] = item.variant.product.product_images
					end
					return_item_hash["tax_rate".to_sym] = item.variant.tax_category_id.present? ? (item.variant.tax_category.tax_rates.first.amount.to_f * 100).to_s : (item.product.tax_category.tax_rates.first.amount.to_f * 100).to_s 
					return_item_hash["item_unit_price".to_sym] = item.variant.price.to_f.round(2).to_s
					return_item_arr.push(return_item_hash)
				end
			end
			return return_item_arr
		end

		def get_returnable_item
			return_item_arr = []
			@order.line_items.each do |item|
				if item.quantity - item.return_quantity(@order) != 0
					return_item_arr.push(item)
				end
			end
			return return_item_arr
		end

	end
end