Spree::StaticContentController.class_eval do 

  def show
    @page = Spree::Page.visible.find_by!(slug: request.path)
  end

end