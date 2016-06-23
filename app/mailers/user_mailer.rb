class UserMailer < ActionMailer::Base

  default from: 'prashant.mishra@w3villa.com'
 
 	def edit_store(user, store, token)
 		@store = store
 		@token = token
 		@user = user
 		mail(to: user.email, subject: 'Edit store instruction')
 	end

 	def notify_store_save(store)
 		@store = store
 		mail(to: "prashant.mishra@w3villa.com", subject: "#{store.name} is created/updated")
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
end
