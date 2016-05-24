class CreateApiToken < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
    	t.string :token
      t.integer :user_id
      t.string :latitude
      t.string :longitude
      t.datetime :expire

      t.timestamps
    end
  end
end
