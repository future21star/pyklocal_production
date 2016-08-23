class ChangeDatatypeOfUserDeviceId < ActiveRecord::Migration
  def up
  	change_column :api_tokens, :user_device_id, :string
  end
  def down
  	change_column :api_tokens, :user_device_id, :integer
  end
end
