class AddResourceIdAndResourceTypeToCarouselImage < ActiveRecord::Migration
  def up
  	add_column :carousel_images, :resource_type, :string
  	add_column :carousel_images, :resource_id, :string
  end

  def down
  	remove_column :carousel_images, :resource_type
  	remove_column :carousel_images, :resource_id
  end
end
