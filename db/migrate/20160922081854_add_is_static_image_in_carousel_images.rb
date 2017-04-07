class AddIsStaticImageInCarouselImages < ActiveRecord::Migration
  def change
    add_column :carousel_images, :is_static, :boolean, default: false
  end
end
