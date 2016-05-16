module ApplicationHelper

	def show_taxanomies?
		(controller.class.to_s == "Spree::HomeController") && (action_name == "index")
	end

  def flash_message
    message = ""
    [:notice, :alert, :success, :error].each do |type|
      if(!flash[type].blank?)
        return {
          text: flash[type],
          type: ((type == :notice) ? 'information' : type)
        }
      end
    end
    return nil;
  end

  def link_to_add_fields_function(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_new_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def return_active_nav(controller, action)
    if (controller == "merchant/products") && (action == "edit")
      "product_details"
    elsif (controller == "merchant/products") && (action == "images")
      "images"
    elsif (controller == "merchant/variants") && (action == "index" || action == "new" || action == "edit")
      "variants"
    elsif (controller == "merchant/products") && (action == "product_properties")
      "product_properties"
    elsif (controller == "merchant/products") && (action == "stock_management")
      "stock_management"
    elsif (controller == "merchant/products") && (action == "stock")
      "stock_management"
    elsif (controller == "merchant/orders") && (action == "edit")
      "order_details"
    elsif (controller == "merchant/orders") && (action == "customer")
      "customer_details"
    elsif (controller == "merchant/orders") && (action == "adjustments")
      "adjustments"
    elsif (controller == "merchant/orders") && (action == "payments")
      "payments"
    elsif (controller == "merchant/orders") && (action == "returns")
      "return_authorizations"
    end
  end

  def active_nav(nav_name)
    highlighted_nav = return_active_nav(params[:controller], params[:action])
    if nav_name == highlighted_nav
      return "active"
    else
      return ""
    end
  end

end
