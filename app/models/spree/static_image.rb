module Spree
  class StaticImage < ActiveRecord::Base

    self.table_name = "carousel_images"

    validate :max_active, on: :create
    validate :max_active_image, on: :update

    has_attached_file :image,
      Pyklocal::Configuration.paperclip_options[:carousel_images][:image]
    validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

    scope :active, -> {where(active: true)}

    private
      
      def max_active
        if self.position == "top"
          if Spree::StaticImage.where(is_static: true, position: "top").active.count >= 2
            self.errors.add(:base, "Maximum active images could not exceeds 2, please inactive some image(s) first")
          end
        elsif self.position == "middle"
          if Spree::StaticImage.where(is_static: true, position: "middle").active.count >= 3
            self.errors.add(:base, "Maximum active images could not exceeds 3, please inactive some image(s) first")
          end
        else
          if Spree::StaticImage.where(is_static: true, position: "bottom").active.count >= 1
            self.errors.add(:base, "Maximum active images could not exceeds 1, please inactive some image(s) first")
          end
        end          
      end

      def max_active_image
        if self.position == "top"
          if Spree::StaticImage.where(is_static: true, position: "top").active.count > 2
            self.errors.add(:base, "Maximum active images could not exceeds 2, please inactive some image(s) first")
          end
        elsif self.position == "middle"
          if Spree::StaticImage.where(is_static: true, position: "middle").active.count > 3
            self.errors.add(:base, "Maximum active images could not exceeds 3, please inactive some image(s) first")
          end
        else
          if Spree::StaticImage.where(is_static: true, position: "bottom").active.count > 1
            self.errors.add(:base, "Maximum active images could not exceeds 1, please inactive some image(s) first")
          end
        end
      end
    
  end
end