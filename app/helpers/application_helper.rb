module ApplicationHelper

  @@current_search_category = "all"

	def show_taxanomies?
		(controller.class.to_s == "Spree::HomeController") && (action_name == "index")
	end

  def static_contents
    Spree::Page.visible
  end

  def flash_message
    message = ""
    [:notice, :alert, :success, :error, :warning, :information, :confirm].each do |type|
      if(!flash[type].blank?)
        return {
          text: flash[type],
          type: ((type == :notice) ? 'information' : type)
        }
      end
    end
    return nil;
  end

  def setCurrentCategory(category)
    @@current_search_category = category
  end

  def getCurrentCategory(category)
    return @@current_search_category
  end

  def get_all_categories_option
    options = "<option value='all'>All</option>"
    Spree::Taxon.all.each do |category|
      if !category.parent_id
        if @@current_search_category == category.name 
          options+="<option value='#{category.name}' selected>#{category.name}</option>"
        else
          options+="<option value='#{category.name}'>#{category.name}</option>"
        end
      end
    end
    return options.html_safe    
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
    elsif (controller == "merchant/images") && (action == "index" || action == "new" || action == "edit")
      "images"
    elsif (controller == "merchant/variants") && (action == "index" || action == "new" || action == "edit")
      "variants"
    elsif (controller == "merchant/product_properties") && (action == "index")
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

  def goto_merchant_path
    if current_spree_user
      if (current_spree_user.has_spree_role?("merchant") && current_spree_user.has_store)
        if current_spree_user.active_store
          link_to "Go to store", main_app.merchant_store_path(current_spree_user.stores.first), "data-no-turbolink" => true
        else
          link_to "Go to store", main_app.merchant_stores_path, "data-no-turbolink" => true
        end
      elsif current_spree_user.has_store
        link_to "Go to store", main_app.merchant_stores_path, "data-no-turbolink" => true
      else
        link_to "Sell with us", main_app.new_merchant_store_path, "data-no-turbolink" => true
      end
    else
      link_to "Sell with us", spree.new_store_application_path, "data-no-turbolink" => true
    end
  end

  def change_states(state, i, order_state, states)
    if state == order_state
      'active'
    elsif i < states.index(order_state)
      'completed'
    end
  end

end
