class CreateUserDevice < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.integer :user_id
      t.integer :device_token
      t.string :device_type
      t.boolean :notification, default: true

      t.timestamps
    end
  end
end
