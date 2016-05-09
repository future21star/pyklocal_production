class StoreTaxon < ActiveRecord::Base
	belongs_to :store
	belongs_to :spree_taxon, foreign_key: :taxon_id, class_name: 'Spree::Taxon'
end
