class CreatePaymentPreferesence < ActiveRecord::Migration
  def change
    create_table :payment_preferences do |t|
      t.integer :user_id
      t.string :a_c_no
      t.string :payee_name
      t.string :bank_name
      t.string :swift_code
      t.string :routing_number

      t.timestamps
    end
  end
end
