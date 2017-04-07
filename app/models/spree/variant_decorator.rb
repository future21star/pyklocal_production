module Spree
  Variant.class_eval do 
  #validates_presence_of :cost_price
 validates :height,:weight,:depth,:width, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 999999.99, :allow_nil => true, :allow_blank => true}

    def option_name
      option_type_value = []
      option_values.each do |option_value|
        option_type_value << "#{option_value.option_type.presentation}: #{option_value.presentation}"
      end
      return option_type_value.join(", ")
    end

    def discount
      if cost_price.to_f == 0
        return 0
      else
        return (((cost_price.to_f - price.to_f) / cost_price.to_f) * 100).round(2)
      end
    end

    def stock_status
      total_on_hand > 0 ? 1 : 0
    end

    def available?
      !discontinued? && product.try(:available?)
    end

    def product_images
      img_arr = []
      if images.present?
        images.each do |image|
          img_arr.push(image.attachment.url(:thumb))
        end
      end
      return img_arr
    end

  end
end