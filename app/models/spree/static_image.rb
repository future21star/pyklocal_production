module Spree
  class StaticImage < ActiveRecord::Base

    self.table_name = "carousel_images"

    validate :max_active

    has_attached_file :image,
      Pyklocal::Configuration.paperclip_options[:carousel_images][:image]
    validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

    scope :active, -> {where(active: true)}

    private
      
      def max_active
        if Spree::StaticImage.where(is_static: true).active.count >= 2
          self.errors.add(:base, "Maximum active images should not exceeds 2, please inactive some image(s) first")
        end
      end
    
  end
end