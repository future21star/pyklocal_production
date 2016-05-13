class UserMailer < ActionMailer::Base

  default from: 'support@coinclub.io'
 
 	def edit_store(user, store, token)
 		@store = store
 		@token = token
 		@user = user
 		mail(to: user.email, subject: 'Edit store instruction')
 	end

 	def notify_store_save(store)
 		@store = store
 		mail(to: "support@coinclub.io", subject: "#{store.name} is created/updated")
 	end

 	def notify_store_approval(user)
 		@store = user.stores.first
 		mail(to: user.email, subject: "#{@store.name} is now approved")
 	end

end
