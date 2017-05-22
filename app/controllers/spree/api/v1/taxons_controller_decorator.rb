module Spree

  Api::V1::TaxonsController.class_eval do

    skip_before_filter :authenticate_user, only: [:index]

    def index
      if taxonomy
        @taxons = taxonomy.root.children
      else
        if current_spree_user.has_spree_role?('merchant') && current_spree_user.stores.present?
          if params[:ids]
            @taxons = current_spree_user.stores.first.spree_taxons.where(id: params[:ids].split(', '))
          else
            @taxons = current_spree_user.stores.first.spree_taxons.order(:taxonomy_id, :lft).ransack(params[:q]).result
            ids = []
            @taxons.each do |category|
              ids.push(category.id)
            end
            query = Spree::Taxon.where(parent_id:ids, id: ids)            
            @taxons = Spree::Taxon.where(query.where_values.map(&:to_sql).join(" OR ")).order(:taxonomy_id, :lft).ransack(params[:q]).result

          end
        else
          if params[:ids]
            @taxons = Spree::Taxon.accessible_by(current_ability, :read).where(id: params[:ids].split(','))
          else
            @taxons = Spree::Taxon.order(:taxonomy_id, :lft).ransack(params[:q]).result
          end
        end
      end 
      @taxons = @taxons.page(params[:page]).per(params[:per_page])   
      # @taxons = all_category
      respond_with(@taxons)
    end

  end

end
