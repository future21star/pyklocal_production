class CreateEmailTokens < ActiveRecord::Migration
  def change
    create_table :email_tokens do |t|
      t.string :token
      t.integer :user_id
      t.integer :resource_id
      t.string :resource_type
      t.boolean :is_valid

      t.timestamps null: false
    end
  end
end
