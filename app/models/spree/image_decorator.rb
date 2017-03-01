module Spree
	Image.class_eval do 
		has_attached_file :attachment,
			Pyklocal::Configuration.paperclip_options[:images][:attachment]
		validates_attachment :attachment, content_type: { content_type: /\Aimage\/.*\Z/ }
		validates_attachment_size :attachment, :in => 0.megabytes..2.megabytes, :message => 'image size must be smaller than 2mb'
	end
end