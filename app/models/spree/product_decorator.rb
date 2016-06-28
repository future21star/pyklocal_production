module Spree
	Product.class_eval do 
		belongs_to :store, class_name: "Merchant::Store"
		has_many :order_variants, -> { order("#{::Spree::Variant.quoted_table_name}.position ASC") },
    inverse_of: :product, class_name: 'Spree::Variant'
    attr_accessor :image_url

    accepts_nested_attributes_for :product_properties, allow_destroy: true

    searchable do
      text :name 
      text :store_name
      latlon(:location) { Sunspot::Util::Coordinates.new(store.try(:latitude), store.try(:longitude)) }

      float :price
    end

    def location
      [store.try(:latitude), store.try(:longitude)].compact.join(", ")
    end

    def store_name
      store.try(:name)
    end

    def self.max_price
      self.all.collect(&:price).max.to_i
    end

    def self.min_price
      self.all.collect(&:price).min.to_i
    end
    
	end
end