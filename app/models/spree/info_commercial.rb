module Spree
	class InfoCommercial < ActiveRecord::Base

    self.table_name = "info_commercials"
		
		has_attached_file :video,
    	Pyklocal::Configuration.paperclip_options[:info_commercials][:videos]

	  validates_attachment_content_type :video, :content_type => /\Avideo\/.*\Z/
	  validates_presence_of :video    

    # has_attached_file :video,
    #   Pyklocal::Configuration.paperclip_options[:carousel_images][:image]

    # scope :active, -> {where(active: true)}	 
	end
end