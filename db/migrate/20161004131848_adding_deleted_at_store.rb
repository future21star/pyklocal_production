class AddingDeletedAtStore < ActiveRecord::Migration
  def change
  	add_column :pyklocal_stores, :deleted_at, :datetime
    add_index  :pyklocal_stores, :deleted_at
  end
end
