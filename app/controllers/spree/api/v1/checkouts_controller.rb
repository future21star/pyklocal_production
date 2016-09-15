Spree::CheckoutsController.class_eval do
	before_action :load_order_with_lock

  include Spree::Core::ControllerHelpers::Auth
  include Spree::Core::ControllerHelpers::Order
  # This before_action comes from Spree::Core::ControllerHelpers::Order
  skip_before_action :set_current_order
  # def next
  #   authorize! :update, @order, order_token
  #   @order.next!
  #   render json: {
  #   	order_detail: (@order, [])
  #   }
  # rescue StateMachines::InvalidTransition
  #   respond_with(@order, default_template: 'spree/api/v1/orders/could_not_transition', status: 422)
  # end
 	# def to_stringify_checkout_json obj ,values = []
 	# 	order_hash=Hash.new
 	# 	skip_order_attributes = ["last_ip_address","created_by_id","approver_id","approved_at","confirmation_delivered","guest_token","canceled_at","store_id"]
 	# 	obj.each do |c_obj|
 	# 		c_obj.attributes.each do |k,v|
 	# 				unless skip_order_attributes.include? k
 	# 					if k.eq?"bill_address_id"  
 	# 						bill_address_hash = Hash.new
 	# 						if v.present?
 	# 							Spree::Address.find(v).attributes.each do |k1,v1|
 	# 								bill_address_hash[k1.to_sym] = v1.to_s
 	# 							end
 	# 							order_hash["bill_address"] = bill_address_hash
 	# 						else
 	# 							order_hash["bill_address"] = ""
 	# 						end
 	# 					end

 	# 					if k.eq?"ship_address_id"  
 	# 						ship_address_hash = Hash.new
 	# 						if v.present?
 	# 							Spree::Address.find(v).attributes.each do |k1,v1|
 	# 								bill_address_hash[k1.to_sym] = v1.to_s
 	# 							end
 	# 							order_hash["bill_address"] = bill_address_hash
 	# 						else
 	# 							order_hash["ship_address"] = ""
 	# 						end
 	# 					end
 	# 				end 
 	# 		end
 	# 	end
 	# 	values.push(main_hash)
 	# end
end