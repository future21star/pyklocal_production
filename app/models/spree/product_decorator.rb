module Spree
	Product.class_eval do 
    validates :name, length: {maximum: 100}
    validates :cost_price, presence: { message: "Retail price can not be blank" }, on: :update
    validates :price, presence: { message: "price can not be blank" }, on: :update
    validate :cost_price_must_be_greater_than_price
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
      text :asin
      boolean :visible
      
      float :price
      float :cost_price
      integer :sell_count
      integer :view_counter
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
      product_properties.where(property_id: properties.find_by_name("UPC").try(:id)).try(:first).try(:value)
    end

    def visible
      if self.cost_price.present? && self.tax_category.present? && self.taxons.present? && self.price.present? && self.total_on_hand > 0 && self.try(:available_on).present? && self.try(:available_on) <= Time.now.to_date 
        if self.try(:discontinue_on).present? 
          if self.try(:discontinue_on) > Time.now.to_date
            return true
          else
            return false
          end
        else
          return true
        end
      else
       return false
     end
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


    def cost_price_must_be_greater_than_price
      if self.cost_price.present? && self.price.present?
        errors.add(:cost_price,"Retail price must be greater than sale price") if self.price.to_f > self.cost_price
      end
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

    # def view_count
    #   impressionist_count(:filter=>:session_hash)
    # end

    def increment_counter
      update_attributes(view_counter: impressionist_count(:filter=>:session_hash))
    end

    def product_property_names
      product_properties.collect(&:value)
    end

    def similar
      if taxon_ids.present?
        similar_products = Sunspot.search(Spree::Product) do
          any_of do
            with(:taxon_ids, taxon_ids)
          end
        end.results - [self]
      elsif taxon_ids.blank? && product_property_names.present?
        similar_products = Sunspot.search(Spree::Product) do
          any_of do
            with(:product_property_name, product_property_names)
          end
        end.results - [self]
      end
    end

    def extracted_facets
      q = 'id: "Product '+self.id.to_s+'"'
      search = Sunspot.search(Spree::Product) do
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
      p dynamic_filters
      {product_property_name: dynamic_filters.flatten.collect(&:value), taxon_ids: search.facet(:taxon_ids).rows.collect(&:value)}
    end

    def self.analize_and_create(name, master_price, sku, available_on, description, shipping_category_id, image_url, store_id, properties, variants,  variant_prices, categories, stock, tax_category, cost_price,upc_code,errors, number_of_rows,total_product)
      begin
        p "----------jjjjkkkllll"
        sell_price = master_price
        retail_price = cost_price

        cost_price_inetger_flag = Integer(master_price) rescue false 
        cost_price_float_flag =  Float(master_price) rescue false
        retail_price_integer_flag = Integer(cost_price) rescue false 
        retail_price_float_flag = Float(cost_price) rescue false

        if  cost_price_inetger_flag == false &&  cost_price_float_flag  == false
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : Sell Price was Invalid."
          errors.push(error)
        end


        if retail_price_integer_flag == false && retail_price_float_flag == false
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : Retail Price was Invalid."
          errors.push(error)
        end

        if cost_price_inetger_flag != false &&  cost_price_float_flag  != false && retail_price_integer_flag != false && retail_price_float_flag !=false
          if master_price.to_f < 0
            Hash error = Hash.new
            error[name.to_sym] = "rows #{number_of_rows} : Sell Price can not be negative"
            errors.push(error)
            sell_price = 0;
          end

          if cost_price.blank? || cost_price.to_f < master_price.to_f
            cost_price = master_price
            Hash error = Hash.new
            error[name.to_sym] = "rows #{number_of_rows} : Product created with retail price same as sell price"
            errors.push(error)
            retail_price = sell_price;
          end
        end

        if master_price.blank?
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : Sell Price was blank."
          errors.push(error)
        end
        # tax_category_id = Spree::TaxCategory.find_by_name("clothing").try(:id)
        # p tax_category_id
        p "================="
        unless Spree::Product.where(name: name, store_id: store_id).present?
          tax_category_id = Spree::TaxCategory.find_by_name(tax_category).try(:id)
          unless tax_category_id.present?
            Hash error = Hash.new
            error[name.to_sym] = "rows #{number_of_rows} : does not have valid tax category"
            errors.push(error)
          end
          p "6666666666"
          p tax_category_id
          product = Spree::Product.new({name: name, price: sell_price, sku: sku, available_on: available_on, description: description, shipping_category_id: shipping_category_id, store_id: store_id, tax_category_id: tax_category_id, cost_price: retail_price})
          p "8888888888666666"
          p product
          if product.save
            total_product = total_product + 1
            if product.price.to_f == 0
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : Product created with sell price zero"
              errors.push(error)
            end
            if product.cost_price.to_f == 0
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : Product created with retail price zero"
              errors.push(error)
            end
            p "99999999999"
            Sunspot.index(product)
            Sunspot.commit
            unless categories.blank?
              product.build_category(product, categories,errors, number_of_rows)
            end
            unless image_url.blank?
              product.build_image(product, image_url,errors, number_of_rows)
            end
            unless properties.blank?
              product.build_property(product, properties,errors, number_of_rows)
            end
            unless variants.blank?
              product.build_variant(product, variants, variant_prices, stock, master_price,errors, number_of_rows)
            end
            if variants.blank? && variant_prices.present? 
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : variants was not provided"
              errors.push(error)
            end
            if stock.present? && variants.blank?
              product.master_variant_stock_build(product, stock,errors)
            end
            if upc_code.present?
              if (Spree::Product.last.properties.collect(&:name) & ["upc"]).blank?
                property = Spree::Property.where(name: "upc", presentation: "Upc").first_or_create
                product_property = product.product_properties.build(value: upc_code, property_id: property.id)
                
                product_property.save
              end
            end
          else
            p "333333"
            Hash error = Hash.new
            error[name.to_sym] = name.to_s + " : " + product.errors.full_messages.join(', ')
            errors.push(error)
            p "666666666"
          end
        else
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : Already Present in store"
          errors.push(error)
        end
      rescue Exception => e
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        p "5555555555555555"
      ensure
        p "00000"
        p total_product
        return errors,total_product
      end
    end

    def build_category(product, categories,errors, number_of_rows)
      begin
        taxon_ids = []
        categories.split(",").each do |category|
          taxon = Spree::Taxon.where(name: category.strip).first
          if taxon.present?
            taxon_ids << taxon.id
          else
            Hash error = Hash.new
            error[name.to_sym] = "rows #{number_of_rows} : #{category} is not a valid category"
            errors.push(error)
            return
          end
        end
        product.update_attributes(taxon_ids: taxon_ids)
      rescue Exception => e
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        errors.push(error)
      end
    end

    def build_image(product, image_url,errors, number_of_rows)
      begin
        image_url.split(",").each do |url|
          image = product.images.build(attachment: url.strip)
          image.save
        end
      rescue Exception => e
        p "(((((((((("
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        p "**********"
        errors.push(error)
      end
    end

    def build_property(product, properties,errors, number_of_rows)
      begin
        properties.split(",").each do |item|
          property_hash = item.split(":")
          property = Spree::Property.where(name: property_hash[0].strip, presentation: property_hash[0].strip.titleize).first_or_create
          product_property = product.product_properties.build(value: property_hash[1].strip.titleize, property_id: property.id)
          product_property.save
        end
      rescue Exception => e
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        errors.push(error)
      end
    end

    def build_variant(product, variants, variant_prices, stock, master_price,errors, number_of_rows)
      begin
        if !variant_prices.present? 
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : variant(s) price(s) was not provided"
          errors.push(error)
          return
        end
        if !variant_prices.present? 
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : variant(s) stock was not provided"
          errors.push(error)
          return
        end
        variant_price_arr = variant_prices.split(',')
        variant_stock_arr = stock.split(',')
        if variants.split(';').count > variant_price_arr.count
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : variant price was not provided for all the variants"
          errors.push(error)
          return
        end
        if variants.split(';').count > variant_stock_arr.count
          Hash error = Hash.new
          error[name.to_sym] = "rows #{number_of_rows} : variant stock was not provided or all the variants"
          errors.push(error)
          return
        end
        i = 0
        variants.split(';').each do |variant|
          option_type_ids = []
          option_value_ids = []
          variant.split(",").each do |item|
            option_fields = item.split(":")
            option_type = Spree::OptionType.where(name: option_fields[0].strip, presentation: option_fields[0].strip.titleize).first_or_create
            option_type_ids << option_type.id
            option_value = Spree::OptionValue.where(name: option_fields[1].strip, presentation: option_fields[1].strip.titleize, option_type_id: option_type.try(:id)).first_or_create
            option_value_ids << option_value.id
          end
          product.update_attributes(option_type_ids: option_type_ids)
          if variant_price_arr.present? && variant_price_arr[i].present?

            cost_price_inetger_flag = Integer(variant_price_arr[i]) rescue false 
            cost_price_float_flag =  Float(variant_price_arr[i]) rescue false
            retail_price_integer_flag = Integer(variant_price_arr[i]) rescue false 
            retail_price_float_flag = Float(variant_price_arr[i]) rescue false


            if  cost_price_inetger_flag == false &&  cost_price_float_flag  == false
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : variant sell Price was Invalid for #{i} variant."
              errors.push(error)

            end


            if retail_price_integer_flag == false && retail_price_float_flag == false
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} :variant Retail Price was Invalid for #{i + 1} variant."
              errors.push(error)
            end

            if  cost_price_inetger_flag == false || cost_price_float_flag  == false || retail_price_integer_flag == false || retail_price_float_flag == false
              return
            end

            if variant_price_arr[i].to_f < 0
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} :variant Retail Price can not be less than zero for #{i + 1} variant."
              errors.push(error)
              return
            end
            variant = product.variants.build(option_value_ids: option_value_ids,price: variant_price_arr[i].to_f)
          else
            variant = product.variants.build(option_value_ids: option_value_ids,price: master_price.to_f)
          end
          variant.save
          if variant_stock_arr.present? && variant_stock_arr[i].present?
            stock_inetger_flag = Integer(variant_stock_arr[i]) rescue false 
            stock_float_flag =  Float(variant_stock_arr[i]) rescue false


            if  stock_inetger_flag == false && stock_float_flag  == false
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : Stock was Invalid for #{i + 1} variant."
              errors.push(error)
              return
            end

            if variant_stock_arr[i].to_f < 0
              Hash error = Hash.new
              error[name.to_sym] = "rows #{number_of_rows} : Stock can not be less than zero for #{i + 1} variant."
              errors.push(error)
              return
            end
            stock_location = Spree::StockLocation.find(1)
            stock_movement = stock_location.stock_movements.build(quantity: variant_stock_arr[i].to_i)
            stock_movement.stock_item = stock_location.set_up_stock_item(variant)
            p "|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
            p stock_location
            p stock_movement
            p stock_movement.stock_item
            p variant_stock_arr[i].to_i
          
            if stock_movement.save
              p "yes saved"
            else
              p "sorry not saved"
              p "***********error*******************"
              p stock_movement.errors.full_messages.to_s
            end
          end
          p variant
          i = i + 1;
        end
      rescue Exception => e
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        errors.push(error)
      end
    end

    def master_variant_stock_build(product, stock,errors, number_of_rows)
      p "555555555555555555"
      p stock
      begin
        stock_location = Spree::StockLocation.find(1)
        stock_movement = stock_location.stock_movements.build(quantity: stock)
        stock_movement.stock_item = stock_location.set_up_stock_item(product.master)
        if stock_movement.save
          p "yes saved"
        else
          p "sorry not saved"
          p "***********error*******************"
          p stock_movement.errors.full_messages.to_s
        end
      rescue Exception => e
        Hash error = Hash.new
        error[name.to_sym] = "rows #{number_of_rows} : #{e.message}"
        errors.push(error)
      end
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