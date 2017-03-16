module Spree
  UserPasswordsController.class_eval do

  	def create
	    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

	    if resource.errors.empty?
	      set_flash_message(:notice, :send_instructions) if is_navigational_format?
	      respond_with resource, :location => spree.login_path
	    else
	    	resource.errors.messages.each do |field,errors|
	    		errors.each do |error|
	    			@error_string += (field.to_s.capitalize + " " + error ) 
	    		end
	    	end
	    	flash[:notice] = @error_string
	      respond_with_navigational(resource) { render :new }
	    end
	  end

  end
end