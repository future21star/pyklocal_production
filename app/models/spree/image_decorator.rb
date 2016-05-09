module Spree
	Image.class_eval do 
		has_attached_file :attachment,
			Pyklocal::Configuration.paperclip_options[:images][:attachment]
		validates_attachment :attachment, content_type: { content_type: /\Aimage\/.*\Z/ }
	end
end