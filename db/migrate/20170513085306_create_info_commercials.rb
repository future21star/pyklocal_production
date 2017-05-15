class CreateInfoCommercials < ActiveRecord::Migration
  def change
    create_table :info_commercials do |t|
      t.attachment :video
      t.boolean :active

      t.timestamps null: false
    end
  end
end
