module Spree
  ProductProperty.class_eval do
    accepts_nested_attributes_for :property
    validates :value, uniqueness: true ,if:  "Spree::Property.where(name: 'upc').collect(&:id).include?(self.property_id)"
  end
end
