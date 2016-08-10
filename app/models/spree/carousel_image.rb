module Spree
  class CarouselImage < ActiveRecord::Base

    self.table_name = "carousel_images"

    has_attached_file :image,
      Pyklocal::Configuration.paperclip_options[:carousel_images][:image]
    validates_attachment :image, content_type: { content_type: /\Aimage\/.*\Z/ }

    scope :active, -> {where(active: true)}
  end
end