Spree::User.class_eval do

  #------------------------ Associations------------------------------
  has_many :store_users, foreign_key: :spree_user_id, class_name: 'Merchant::StoreUser'
  has_many :stores, through: :store_users, class_name: 'Merchant::Store' 
  has_many :ordered_line_items, through: :orders, :source => :line_items, class_name: 'Spree::LineItem'
  has_many :raitings, foreign_key: :spree_user_id
  has_many :parse_links, foreign_key: :user_id, class_name: 'Spree::ParseLink'
  has_many :api_tokens
  has_many :user_devices
  has_many :payment_histories, foreign_key: :user_id, class_name: 'Spree::PaymentHistory'
  has_many :drivers_line_items, -> {where(spree_line_items: {is_pickedup: true, delivery_type: "home_delivery", ready_to_pick: true})}, foreign_key: :driver_id, class_name: 'Spree::LineItem'
  belongs_to :spree_buy_privilege
  belongs_to :spree_sell_privilege 
  has_one :payment_preference, foreign_key: :user_id, class_name: 'Spree::PaymentPreference'
  has_many :driver_orders, foreign_key: :driver_id, class_name: "Spree::DriverOrder"
  has_many :cart_orders, through: :driver_orders, class_name: "Spree::Order"
  
  #---------------------Callbacks--------------------------
  after_create :assign_api_key 
  after_create :notify_admin
  after_update :notify_user
  attr_accessor :role_name
  accepts_nested_attributes_for :parse_links, :reject_if => lambda { |a| a[:url].blank? }

  def mailboxer_email(object)
    return email
  end

  def driver_orders_list
    orders = []
    Merchant::Store.all.each do |store|
      store.spree_products.each do |store_prodct|
        store_prodct.line_items.where(delivery_state: "confirmed_pickup", delivery_type: "home_delivery", driver_id: id).collect(&:order).uniq.each do |store_order|
          orders << {order_number: store_order.number, store_name: store.name}
        end
      end
    end
    return orders
  end

  def drivers_cart
    orders = []
    driver_orders.where(is_delivered: false).each do |d_order|
      orders << {order_number: d_order.cart_order.number, store_name: d_order.store_name}
    end
    return orders
  end

  def has_store
    stores.present?
  end

  def active_store
    if stores.present?
      stores.first.active
    end
  end

  def full_name
    if first_name 
      [first_name, last_name].compact.join(" ")
    else
      email
    end
  end

  def full_address
    if bill_address
      [bill_address.address1, bill_address.address2].compact.join(" ")
    else
      "D-42 Sector 59"
    end
  end

  def ordered_products
    ordered_line_items.map{|o| o.product}
  end

  def review_product?(product)
    ordered_products.include?(product)
  end

  def ordered_from_stores
    ordered_products.map{|p| p.store}.uniq
  end

  def review_store?(store)
    ordered_from_stores.include?(store)
  end

  def store_product_line_items
    store_line_items = []
    stores.first.spree_products.each do |product|
      store_line_items << product.line_items
    end
    return store_line_items.flatten
  end

  def store_orders
    store_product_line_items.collect(&:order).uniq.flatten
  end

  def notify_admin
    if self.role_name == "driver"
      UserMailer.request_driver_approval(self).deliver
    end
  end

  private

    def assign_api_key
      self.generate_spree_api_key!
    end

    def notify_user
      if self.spree_role_ids.include?(Spree::Role.where(name: "merchant").first.try(:id)) && stores.present? && !stores.first.try(:active)
        stores.first.update_attributes(active: true)
        UserMailer.notify_store_approval(self).deliver
      elsif self.spree_role_ids.include?(Spree::Role.where(name: "driver").first.try(:id))
        UserMailer.notify_driver_approval(self).deliver
      end
    end

    

end
