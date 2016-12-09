# Configure Spree Preferences
#
# Note: Initializing preferences available within the Admin will overwrite any changes that were made through the user interface when you restart.
#       If you would like users to be able to update a setting with the Admin it should NOT be set here.
#
# Note: If a preference is set here it will be stored within the cache & database upon initialization.
#       Just removing an entry from this initializer will not make the preference value go away.
#       Instead you must either set a new value or remove entry, clear cache, and remove database entry.
#
# In order to initialize a setting do:
# config.setting_name = 'new value'
Spree.config do |config|
  # Example:
  # Uncomment to stop tracking inventory levels in the application
  # config.track_inventory_levels = false
  config.logo = "/images/pyc-logo.png"
end

Spree::Store.current.name = "Pyklocal"

Spree::PrintInvoice::Config.set(logo_path: "pyc_logo.png")
Spree::PrintInvoice::Config.set(next_number: 1|1234)
# Spree::PrintInvoice::Config.set(buttons: 'invoice')
Spree::PrintInvoice::Config.set(page_layout: :landscape, page_size: 'A4')
Spree::PrintInvoice::Config.set(store_pdf: true)
Spree::PrintInvoice::Config.set(storage_path: 'pdfs/orders')

Spree.user_class = "Spree::LegacyUser"
Spree::PermittedAttributes.line_item_attributes.push :delivery_type, :in_wishlist
Spree::PermittedAttributes.user_attributes.push :is_guest, :first_name, :last_name ,:mobile_number, :t_and_c_accepted, stores_attributes: [:name, :certificate, :estimated_delivery_time, :active, :payment_mode, :description, :manager_first_name, :manager_last_name, :phone_number, :store_type, :street_number, :city, :state, :zipcode, :country, :site_url, :terms_and_condition, :payment_information, :logo, spree_taxon_ids: [], store_users_attributes: [:spree_user_id, :store_id, :id]]
Spree::PermittedAttributes.product_attributes.push :asin
Spree::PermittedAttributes.address_attributes.push :user_id
Spree::BackendConfiguration.class_eval do 
	SELLER_TAB			||= [:merchants]
  COMMISSION_TAB      ||= [:commission]
  CAROUSEL_IMAGE_TAB  ||= [:carousel_image]
  FEEDBACK_TAB  ||= [:feedback]
  STATIC_IMAGE_TAB  ||= [:static_image]
end