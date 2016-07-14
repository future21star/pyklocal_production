module Spree
  Api::V1::UsersController.class_eval do 

    include Spree::Api::ApiHelpers

    before_filter :find_user, only: [:my_pickup_list, :update_location, :update, :pickup, :my_cart, :add_to_cart, :remove_from_cart, :my_delivery_list, :mark_as_deliver]
    skip_before_filter :authenticate_user, only: [:my_pickup_list, :update_location, :pickup, :update, :my_cart, :add_to_cart, :remove_from_cart, :my_delivery_list, :mark_as_deliver]

    # Adding user_devices data regarding a driver
    def user_devices
      @api_token = Spree::ApiToken.where(token: params[:user_id]).first
      @user = @api_token.try(:user)
      if @user
        @user_device = @user.user_devices.where(device_token: params[:user_device][:device_token], device_type: params[:user_device][:device_type]).first_or_initialize
        if @user_device.new_record?
          @user_device.attributes = user_device_param.merge(user_id: @user.id)
          if @user_device.save
            @response = get_response
          else
            @response = error_response
            @response[:message] = @user_device.errors.full_messages.join(", ")
          end
        else
          @response = get_response
        end
      else
        @response = get_response
        @response[:message] = "User not found, invalid token."
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    # add_cart_cart a order if order is ready_to_pick
    def add_to_cart
      success = true
      message = ""
      params[:order_object].each do |obj|
        line_item_ids = []
        store = Merchant::Store.find_by_name(obj["store_name"])
        order = Spree::Order.find_by_number(obj["order_number"])
        order.line_items.where(delivery_type: "home_delivery").each do |line_item|
          if line_item.product.store_id == store.id
            line_item_ids << line_item.id
          end
        end
        if @user.driver_orders.where(order_id: order.id, line_item_ids: line_item_ids.join(", ")).blank?
          Spree::LineItem.where(id: line_item_ids).update_all(delivery_state: "in_cart")
          Spree::DriverOrder.create(order_id: order.id, driver_id: @user.id, line_item_ids: line_item_ids.join(", "))
        else
          success = false
          message = "Some of your order may already present in your cart"
        end
      end
      if success
        @response = get_response
        @response[:message] = "Successfully added into cart"
      else
        @response = error_response
        @response[:message] = message
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    # See list of orders in a drivers cart
    def my_cart
    rescue Exception => e
      api_exception_handler(e)
    ensure
      if @user.try(:drivers_cart).present?
        render json: @user.drivers_cart.as_json
      else
        @response = error_response
        @response[:message] = "No cart item available"
        render json: @response
      end
    end

    # Remove orders form driver's cart
    def remove_from_cart
      params[:cancel_orders].each do |cancel_order|
        @order = Spree::Order.find_by_number(cancel_order["order_number"])
        @driver_orders = @user.driver_orders.where(order_id: @order.id,line_item_ids: cancel_order["line_item_ids"].join(", "))
        if @driver_orders.present?
          Spree::LineItem.where(id: cancel_order["line_item_ids"]).update_all(delivery_state: "ready_to_pick")
          @driver_orders.delete_all
          @response = get_response
          @response[:message] = "Successfully removed from cart"
        else
          @response = error_response
          @response[:message] = "Item not found in cart"
        end
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    def pickup
      driver_id = eval(params[:option]) ? nil : @user.try(:id)
      updating_value = eval(params[:option]) ? @user.try(:id) : nil
      # state = eval(params[:option]) ? "in_cart" : "confirmed_pickup"
      state_update = eval(params[:option]) ? "confirmed_pickup" : "ready_to_pick"
      params[:line_items_object].each do |item_object|
        @line_items = Spree::LineItem.where(id: item_object["line_item_ids"], delivery_type: "home_delivery", driver_id: driver_id)
        if @line_items.present?
          @line_items.find_each { |line_item| line_item.update_attributes(delivery_state: state_update, driver_id: updating_value) }
          if eval(params[:option]) == false
            item_object["line_item_ids"].join(", ")
            @result= Spree::DriverOrder.where( line_item_ids:item_object["line_item_ids"].join(", ")).first
            if @result.present?
              @result.delete
            end
            @response = get_response
            @response[:message] = "You have canceled this pickup"
          else
            @response = get_response
            @response[:message] =  "Item(s) picked up by you"
          end
        else
          @response = error_response
          @response[:message] = "Item not found either cancel by seller or picked up by another driver."
        end
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    def my_pickup_list
      @orders = @user.driver_orders_list
      p "========================="
      p @orders
      p "========================"
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @orders.as_json()
    end

    def mark_as_deliver
      @order = Spree::Order.find_by_number(params[:order_number])
      @line_items = @order.line_items.where(id: params[:line_item_ids], delivery_state: "out_for_delivery")
      if @line_items.present?
        @line_items.update_all(delivery_state: "delivered")
        @user.driver_orders.where(order_id: @order.try(:id), line_item_ids: params[:line_item_ids].join(", "))
        @response = get_response
        @response[:message] = "Successfully delivered"
      else
        @response = error_response
        @response[:message] = "Line item or order not present"
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    def my_delivery_list
    rescue Exception => e
      api_exception_handler(e)
    ensure
      if @user.try(:delivered_orders).present?
        render json: @user.delivered_orders.as_json
      else
        @response = error_response
        @response[:message] = "No order(s) available"
        render json: @response
      end
    end

    def update
      if @user.update_attributes(user_params)
        @response = get_response
      else
        @response = error_response
        @response[:message] = @user.errors.full_messages.join(", ")
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    def update_location
      if @user.api_tokens.last.update_attributes(latitude: params[:latitude], longitude: params[:longitude])
        @response = get_response
      else
        @response = error_response
        @response[:message] = @user.errors.full_messages.join(", ")
      end
    rescue Exception => e
      api_exception_handler(e)
    ensure
      render json: @response
    end

    private

      def user
        @user = Spree::ApiToken.where(token: params[:user_id]).first.try(:user)
      end

      def user_device_param
        params.require(:user_device).permit(:device_token, :device_type, :user_id, :notification)
      end

      def find_user
        id = params[:id] || params[:user_id]
        @user = Spree::ApiToken.where(token: id).first.try(:user)
      end
  end
end