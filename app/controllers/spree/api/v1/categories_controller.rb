module Spree
  class Api::V1::CategoriesController < Spree::Api::BaseController

    skip_before_filter :authenticate_user

    def index
      render json: {
        status: 1,
        message: "Categories Listing",
        details: Spree::Taxonomy.first.root.children.as_json({
          only: [:id, :parent_id, :name, :position, :level],
          methods: [:sub_categories]
        })
      }
    end

  end
end