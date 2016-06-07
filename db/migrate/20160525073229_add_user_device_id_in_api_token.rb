class AddUserDeviceIdInApiToken < ActiveRecord::Migration
  def change
  	add_column :api_tokens, :user_device_id, :integer
  end
end
