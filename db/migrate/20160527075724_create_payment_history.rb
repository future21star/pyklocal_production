class CreatePaymentHistory < ActiveRecord::Migration
  def change
    create_table :payment_histories do |t|
      t.integer :user_id
      t.string :transaction_number
      t.decimal :amount
      t.decimal :amount_due

      t.timestamps
    end
  end
end
