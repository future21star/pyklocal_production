module Spree
	Product.class_eval do 
		belongs_to :store, class_name: "Merchant::Store"
		has_many :order_variants, -> { order("#{::Spree::Variant.quoted_table_name}.position ASC") },
    inverse_of: :product, class_name: 'Spree::Variant'
    attr_accessor :image_url

    searchable do
      text :name 
      text :store_name
      latlon(:location) { Sunspot::Util::Coordinates.new(store.try(:latitude), store.try(:longitude)) }

      float :price

      dynamic_string :product_property_ids, :multiple => true do
        product_properties.inject(Hash.new { |h, k| h[k] = [] }) do |map, product_property| 
          map[product_property.property_id] << product_property.value
          map
        end
      end

      integer :taxon_ids, references: Spree::Taxon, multiple: true do
        taxons.collect { |t| t.self_and_ancestors.map(&:id) }.flatten
      end

      string :product_property_name, references: Spree::ProductProperty, multiple: true do
        product_properties.collect { |p| p.value }.flatten
      end
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

    def similar
      similar_products = Sunspot.search(Spree::Product) do
        
        any_of do
          with(:taxon_ids, extracted_facets[:taxon_ids])
          with(:product_property_name, extracted_facets[:product_property_name])
        end
      end.results - [self]
    end

    def extracted_facets
      q = 'id: "Product '+self.id.to_s+'"'
      search = Sunspot.search(Spree::Product) do
        adjust_solr_params do |params|
          params[:q] = q
        end
        dynamic(:product_property_ids) do
          Spree::Property.all.each do |property|
            facet(property.id)
          end
        end
        facet(:taxon_ids)
      end
      dynamic_filters = []
      Spree::Property.all.each do |property|
        dynamic_filters << search.facet("product_property_ids", property.id).rows
      end
      {product_property_name: dynamic_filters.flatten.collect(&:value), taxon_ids: search.facet(:taxon_ids).rows.collect(&:value)}
    end
    
	end
end