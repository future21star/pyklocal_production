module Spree
	Product.class_eval do 
		belongs_to :store, class_name: "Merchant::Store"
		has_many :order_variants, -> { order("#{::Spree::Variant.quoted_table_name}.position ASC") },
    inverse_of: :product, class_name: 'Spree::Variant'
    has_many :comments, as: :commentable
    has_many :ratings, as: :rateable

    attr_accessor :image_url

    after_create :save_image

    is_impressionable

    accepts_nested_attributes_for :product_properties, allow_destroy: true
    accepts_nested_attributes_for :variant_images

    self.whitelisted_ransackable_associations = %w[stores variants_including_master master variants store orders line_items price impressions]
    self.whitelisted_ransackable_attributes = %w[description name slug view_counter]

    searchable do
      text :name 
      text :store_name
      text :upc_code
      text :meta_keywords
      text :sku
      latlon(:location) { Sunspot::Util::Coordinates.new(store.try(:latitude), store.try(:longitude)) }

      float :price
      integer :sell_count
      integer :view_count
      boolean :buyable

      time :created_at

      dynamic_string :product_property_ids, :multiple => true do
        product_properties.inject(Hash.new { |h, k| h[k] = [] }) do |map, product_property| 
          map[product_property.property_id] << product_property.value
          map
        end
      end

      string :store_name

      integer :store_id

      string :brand_name, references: Spree::ProductProperty, multiple: true do
        product_properties.where(property_id: properties.where(name: "Brand").first.try(:id)).collect { |p| p.value }.flatten
      end

      string :taxon_name, references: Spree::Taxon, multiple: true do
        taxons.where.not(name: "categories").collect(&:name).flatten
      end

      integer :taxon_ids, references: Spree::Taxon, multiple: true do
        taxons.collect { |t| t.self_and_ancestors.map(&:id) }.flatten
      end

      string :product_property_name, references: Spree::ProductProperty, multiple: true do
        product_properties.collect { |p| p.value }.flatten
      end
    end

    def upc_code
      product_properties.where(property_id: properties.find_by_name("UPC Code").try(:id)).try(:first).try(:value)
    end

    def in_wishlist(user)
      variant_id_arr = variants.collect(&:id)
      variant_id_arr.push(master.id)
      unless user.wishlists.blank?
        variant_id_arr.each do |variant|
          @wish = user.wishlists.where(variant_id: variant)
          unless @wish.blank?
            return "1"
          end
        end
      end
      return "0"
    end

    def discount
      if cost_price.to_f == 0
        return 0
      else
        return (((cost_price.to_f - price.to_f) / cost_price.to_f) * 100).round(2)
      end
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

    def stock_status
      total_on_hand > 0 ? 1 : 0
    end

    def average_ratings
      if ratings.present?
        (ratings.sum(:rating) / ratings.count).to_f.round(2).to_s
      else
        0
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

    def sell_count
      line_items.joins(:order).where(spree_orders: {state: "complete"}).count
    end

    def view_count
      impressionist_count(:filter=>:session_hash)
    end

    def increment_counter
      update_attributes(view_counter: impressionist_count(:filter=>:session_hash))
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

    def self.analize_and_create(name, master_price, sku, available_on, description, shipping_category_id, image_url, store_id, properties, variants, categories)
      p "*************************************************************************************************************"
      p Spree::Product.where(name: name, store_id: store_id).present?
      unless Spree::Product.where(name: name, store_id: store_id).present?
        product = Spree::Product.new({name: name, price: master_price, sku: sku, available_on: available_on, description: description, shipping_category_id: shipping_category_id, store_id: store_id})
        product.save
        unless categories.blank?
          product.build_category(product, categories)
        end
        unless image_url.blank?
          product.build_image(product, image_url)
        end
        unless properties.blank?
          product.build_property(product, properties)
        end
        unless variants.blank?
          product.build_variant(product, variants)
        end
      end
    end

    def build_category(product, categories)
      taxon_ids = []
      categories.split(",").each do |category|
        taxon = Spree::Taxon.where(permalink: category.strip).first
        if taxon.present?
          taxon_ids << taxon.id
        end
      end
      product.update_attributes(taxon_ids: taxon_ids)
    end

    def build_image(product, image_url)
      image_url.split(",").each do |url|
        image = product.images.build(attachment: url.strip)
        image.save
      end
    end

    def build_property(product, properties)
      properties.split(",").each do |item|
        property_hash = item.split(":")
        property = Spree::Property.where(name: property_hash[0].strip, presentation: property_hash[0].strip.titleize).first_or_create
        product_property = product.product_properties.build(value: property_hash[1].strip.titleize, property_id: property.id)
        product_property.save
      end
    end

    def build_variant(product, variants)
      option_type_ids = []
      option_value_ids = []
      variants.split(",").each do |item|
        option_fields = item.split(":")
        option_type = Spree::OptionType.where(name: option_fields[0].strip, presentation: option_fields[0].strip.titleize).first_or_create
        option_type_ids << option_type.id
        option_value = Spree::OptionValue.where(name: option_fields[1].strip, presentation: option_fields[1].strip.titleize, option_type_id: option_type.try(:id)).first_or_create
        option_value_ids << option_value.id
      end
      product.update_attributes(option_type_ids: option_type_ids)
      variant = product.variants.build(option_value_ids: option_value_ids)
      variant.save
    end

    private
      def save_image
        if image_url.present?
          image = images.new({attachment: image_url})
          image.save
        end
      end
    
	end
end