module Spree
  Variant.class_eval do 

    def option_name
      option_type_value = []
      option_values.each do |option_value|
        option_type_value << "#{option_value.option_type.presentation}: #{option_value.presentation}"
      end
      return option_type_value.join(", ")
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