class AddColumnInCarouselImages < ActiveRecord::Migration
  def change
    add_column :carousel_images, :url, :string
    add_column :carousel_images, :position, :string
  end
end
