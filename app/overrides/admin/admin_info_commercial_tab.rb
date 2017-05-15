Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-info-commercial-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/info_commercial_tab",
  :disabled => false
)