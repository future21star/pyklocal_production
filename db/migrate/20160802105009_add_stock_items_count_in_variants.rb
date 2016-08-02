class AddStockItemsCountInVariants < ActiveRecord::Migration
  def change
    add_column :spree_variants, :stock_items_count, :integer, default: 0, null: false
  end
end
