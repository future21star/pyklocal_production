Spree::User.class_eval do

  devise :registerable
  devise :confirmable 
  validates :first_name, :last_name, presence: true
  # validates :password,:email, presence: true, on: :create
  validates :first_name, :last_name, length: {maximum: 100}
  before_destroy :destroy_store
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
  has_one  :address, class_name: 'Spree::Address'
  has_many :wishlists
  has_many :authentications
  has_many :ratings, foreign_key: :user_id
  has_many :comments, foreign_key: :user_id
  has_many :customer_returns, class_name: 'Spree::CustomerReturn'

  # ----------------------Validations----------------------------
  validate :t_and_c, on: :create
  #validates_presence_of :first_name, :last_name
  #---------------------Callbacks--------------------------
  after_create :assign_api_key 
  after_create :notify_admin
  after_create :subscribe_user_to_mailing_list
  after_update :notify_user
  after_update :send_changed_password_notification
  attr_accessor :role_name

  accepts_nested_attributes_for :parse_links, :reject_if => lambda { |a| a[:url].blank? }
  accepts_nested_attributes_for :stores, allow_destroy: true
  accepts_nested_attributes_for :store_users, allow_destroy: true

  def mailboxer_email(object)
    return email
  end

  def confirmation_required?
    self.registration_type == "customer"
  end

  def driver_orders_list
    orders = []
    if driver_orders.present?
      driver_orders.each do |d_order|
        order = d_order.cart_order
        if order.state != 'canceled'
          line_items = order.line_items.where(id: d_order.line_item_ids.split(", "))
          line_items = line_items.where("delivery_state = ? OR delivery_state = ?", "confirmed_pickup", "out_for_delivery")
          if line_items.present?
            store_name = line_items.first.product.store_name
            store_address = line_items.first.product.store.try(:address)
            p "************************************************"
            p store_address
            p d_order
            state = line_items.collect(&:delivery_state).uniq.join
            unless store_address.nil?
              orders << {order_number: order.number, line_item_ids: line_items.collect(&:id), state: state, store_name: store_name, store_address: store_address}
            end
          end
        end
      end
    end
    return orders.uniq
  end

  def cart_count
    cart_count_sum = 0
    # @order = orders.where("state != ? AND state != ? AND state != ?","complete","canceled","returned").last
    @order = self.last_incomplete_spree_order
    unless @order.blank?
      @order.line_items.each do |line_item|
        cart_count_sum = cart_count_sum + line_item.quantity
      end
      return cart_count_sum
    end
    return 0
  end

  def wishlist_variant_ids
    self.wishlists.collect(&:variant_id)
  end

  def drivers_cart
    orders = []
    driver_orders.where(is_delivered: false).each do |d_order|
      if d_order.cart_order.present?
        if d_order.cart_order.line_items.where(id: d_order.line_item_ids.split(", "), delivery_state: "in_cart").present?
          orders << {order_number: d_order.cart_order.number, store_name: d_order.store_name, line_item_ids: d_order.line_item_ids.split(", "), state: "in_cart"}
        end
      end
    end
    return orders
  end

  def delivered_orders
    orders = []
    driver_orders.where(is_delivered: true).each do |d_order|
      orders << {order_number: d_order.cart_order.number, store_name: d_order.store_name, line_item_ids: d_order.line_item_ids.split(", ")}
    end
    return orders
  end

  def has_store
    stores.present?
  end

  def destroy_store
    if stores.present?
      stores.first.destroy
    end
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

  # def store_product_line_items
  #   store_line_items = []
  #   stores.first.spree_products.each do |product|
  #     store_line_items << product.line_items
  #   end
  #   return store_line_items.flatten
  # end

  # def store_orders
  #   store_product_line_items.collect(&:order).uniq.flatten
  # end

  def notify_admin
    if self.role_name == "driver"
      UserMailer.request_driver_approval(self).deliver
    end
  end

  private

    def assign_api_key
      self.generate_spree_api_key!
    end

    def subscribe_user_to_mailing_list
      SubscribeUserToMailingListJob.perform_later(self)
    end


    # def notify_store_destroy
    #   if self.has_store
    #     UserMailer.notify_user_store_destroy(self).deliver_now
    #   end
    # end

    def notify_user
      if self.has_spree_role?('merchant') && stores.present? && !stores.first.try(:active)
        stores.first.update_attributes(active: true)
        UserMailer.notify_store_approval(self).deliver_now
      end
    end

    def send_changed_password_notification
      if self.changes.include?(:password_salt) && !self.changes.include?(:created_at)
        unless self.changes.include?(:deleted_at)
          UserMailer.password_changed_notification(self).deliver_now
        end
      end
    end

    def t_and_c
       p self.t_and_c_accepted.blank?
      if self.t_and_c_accepted.blank?
        self.errors.add(:base, "Privacy policy should be accepted")
      end
    end

end
