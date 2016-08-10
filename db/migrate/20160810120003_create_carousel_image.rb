class CreateCarouselImage < ActiveRecord::Migration
  def change
    create_table :carousel_images do |t|
      t.attachment :image
      t.boolean :active

      t.timestamps
    end
  end
end
