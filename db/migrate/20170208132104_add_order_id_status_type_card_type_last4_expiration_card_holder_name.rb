class AddOrderIdStatusTypeCardTypeLast4ExpirationCardHolderName < ActiveRecord::Migration
  def change
  	add_column :spree_refunds, :order_id, :integer
  	add_column :spree_refunds, :type, :string
  	add_column :spree_refunds, :card_type, :string
  	add_column :spree_refunds, :status, :string
  	add_column :spree_refunds, :last_card_digits, :integer
  	add_column :spree_refunds, :expiration, :string
  end
end
