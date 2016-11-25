Deface::Override.new(
  :virtual_path => "spree/layouts/admin",
  :name => "admin-feedback-tab",
  :insert_bottom => "[data-hook='admin_tabs']",
  :partial => "spree/admin/hooks/feedback_tab",
  :disabled => false
)