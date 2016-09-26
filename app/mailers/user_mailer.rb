class UserMailer < ActionMailer::Base

  default from: 'admin@pyklocal.com'
 
 	def edit_store(user, store, token)
 		@store = store
 		@token = token
 		@user = user
 		mail(to: user.email,from: 'admin@pyklocal.com', subject: 'Edit store instruction')
 	end

 	def notify_store_save(store)
 		@store = store
 		mail(to: "prashant.mishra@w3villa.com",from: 'admin@pyklocal.com', subject: "#{store.name} is created/updated")
 	end

  def password_changed_notification(user)
    @user = user
    mail(to: @user.email,from: 'admin@pyklocal.com', subject: "Notice of Password Change from Pyklocal")
  end

  def notify_user_store_save(store)
    @store = store
    mail(to: @store.spree_users.first.email,from: 'admin@pyklocal.com', subject: "#{store.name} Is Created")
  end  

 	def notify_store_approval(user)
 		@store = user.stores.first
 		mail(to: user.email,from: 'admin@pyklocal.com', subject: "#{@store.name} is now approved")
 	end

 	def request_driver_approval(user)
 		@user = user
 		mail(from: "#{user.email}", to: "prashant.mishra@w3villa.com", subject: "#{@user.full_name} is requested add as a driver" )
 	end

 	def notify_driver_approval(user)
 		@user = user
 		mail(to: user.email,from: 'admin@pyklocal.com', subject: "#{@user.full_name} is now approved as a driver")
 	end

  def delivery_notification_user(user, order)
    @order = order
    @user = user
    mail(to: @user.email,from: 'admin@pyklocal.com', subject: "Delivery Confirmation")
  end

  def delivery_notification_store(store, order)
    @order = order
    @store = store
    @seller = @store.try(:spree_users).try(:first)
    mail(to: @seller.try(:email),from: 'admin@pyklocal.com', subject: "Delivery Confirmation")
  end
end
