module Spree
  ProductProperty.class_eval do
    accepts_nested_attributes_for :property
  end
end
