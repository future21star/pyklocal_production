module Spree
	Taxon.class_eval do

    def sub_categories
      children.as_json({
        only: [:id, :parent_id, :name, :position, :level],
        methods: [:sub_categories]
      })
    end

	end
end