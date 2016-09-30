Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-static-image-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/static_image_tab",
  :disabled => false
)