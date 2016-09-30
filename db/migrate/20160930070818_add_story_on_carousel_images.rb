class AddStoryOnCarouselImages < ActiveRecord::Migration
  def change
    add_column :carousel_images, :story, :text
  end
end
