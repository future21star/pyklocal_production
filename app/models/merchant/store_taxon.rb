module Merchant
	class StoreTaxon < ActiveRecord::Base
		self.table_name = "pyklocal_stores_taxons"
	  acts_as_paranoid

		belongs_to :store, class_name: 'Merchant::Store'
		belongs_to :spree_taxon, foreign_key: :taxon_id, class_name: 'Spree::Taxon'
		# after_create :add_subtaxon

		def add_subtaxon
			p "hjhjhjhjhjhjhjhjhj"
			p self.store.id
			p  self.spree_taxon.children.count
			if self.spree_taxon.children.present?
				self.spree_taxon.children.each do |taxon|
					p "898989898989898989898"
					@store_taxon = Merchant::StoreTaxon.where(store_id: self.store.id,taxon_id: taxon.id).new
					@store_taxon.save
				end
			end
		end

	end
end
