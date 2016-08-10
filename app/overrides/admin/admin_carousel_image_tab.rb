Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-carousel-image-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/carousel_image_tab",
  :disabled => false
)