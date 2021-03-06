class UserMailer < ActionMailer::Base

  default from: 'sales@pyklocal.com'
  # default from: 'admin@pyklocal.com'
 
 	def edit_store(user, store, token)
 		@store = store
 		@token = token
 		@user = user
 		mail(to: user.email,from: 'admin@pyklocal.com', subject: 'Edit store instruction')
 	end

 	def notify_store_save(store)
 		@store = store
 		mail(to: "gopal.sharma@w3villa.com", subject: "#{store.name} is created/updated")
 	end

  def notify_out_of_stock_product(variant)
    @variant = variant
    @product = variant.product
    @seller = @product.store.try(:spree_users).try(:first)
    if @seller
      mail(to: @seller.email, subject: "Product Out Of Stock")
    end
  end

  def notify_small_amount_of_product(variant) 
    @variant = variant
    @product = variant.product
    @seller = @product.store.try(:spree_users).try(:first)
    if @seller
      mail(to: @seller.email, subject: "Product stock is less than 5")
    end
  end

  def password_changed_notification(user)
    @user = user
    mail(to: @user.email, subject: "Notice of Password Change from Pyklocal")
  end

  def notify_user_store_save(store)
    @store = store
    mail(to: @store.spree_users.first.email, subject: "#{store.name} Is Created")
  end  

  def notify_user_store_destroy(user)
    @user = user
    mail(to: @user.email, subject: "Store Remove Notification")
  end

 	def notify_store_approval(user)
 		@store = user.stores.first
 		mail(to: user.email, subject: "#{@store.name} is now approved")
 	end

 	def request_driver_approval(user)
 		@user = user
 		mail(from: "#{user.email}", to: "prashant.mishra@w3villa.com", subject: "#{@user.full_name} is requested add as a driver" )
 	end

 	def notify_driver_approval(user)
 		@user = user
 		mail(to: user.email, subject: "#{@user.full_name} is now approved as a driver")
 	end

  def delivery_notification_user(user, order)
    @order = order
    @user = user
    mail(to: @user.email, subject: "Delivery Confirmation")
  end

  def delivery_notification_store(store, order)
    @order = order
    @store = store
    @seller = @store.try(:spree_users).try(:first)
    mail(to: @seller.try(:email), subject: "Delivery Confirmation")
  end

  def notify_items_out_for_delivery(line_items)
    @user = line_items.first.order.user
    @line_items = line_items
    mail(to: @user.email, from: "sales@pyklocal.com",subject: "Out For Delivery")
  end

  def notify_order_items_delivered(order)
    p "7777777777777"
    @order = order
    @user = order.user
    mail(to: @user.email ,from: "sales@pyklocal.com",subject: "PykLocal Order Delivered Confirmation")
  end

  def notify_seller_cancel_order(order,email)
    @seller = Spree::User.with_deleted.find_by_email(email)
    @order = order
    mail(to: @email , subject: "PykLocal Order Cancel ")
  end
end
