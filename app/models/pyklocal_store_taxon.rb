class PyklocalStoreTaxon < ActiveRecord::Base
	self.table_name = "pyklocal_stores_taxons"
	belongs_to :pyklocal_store
	belongs_to :spree_taxon, foreign_key: :taxon_id, class_name: 'Spree::Taxon'
end
