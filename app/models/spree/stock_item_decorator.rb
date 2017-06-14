module Spree
  StockItem.class_eval do
    before_save :notify_seller_about_out_of_stock

    private

      def notify_seller_about_out_of_stock
      	p "888888888888888888888888888888"
        if self.changes.include?(:count_on_hand) && (count_on_hand <= 0)
         	UserMailer.notify_out_of_stock_product(variant).deliver_now
        end

        if self.changes.include?(:count_on_hand) && (count_on_hand <= 5)
          UserMailer.notify_small_amount_of_product(variant).deliver_now
        end
      end

  end
end