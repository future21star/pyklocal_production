module Spree
  class Api::V1::CategoriesController < Spree::Api::BaseController

    skip_before_filter :authenticate_user

    def index
      # @categories = []
      # Spree::Taxonomy.first.root.children.each do |category|
      #   @categories << {
      #     category_id: category.id,
      #     parent_id: category.parent_id,
      #     name: category.name,
      #     position: category.position,
      #     level: category.level,
      #     children: category.children.as_json({
      #       only: [:id, :parent_id, :name, :position, :level],
      #       methods: [:children]
      #     })
      #   }
      # end
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