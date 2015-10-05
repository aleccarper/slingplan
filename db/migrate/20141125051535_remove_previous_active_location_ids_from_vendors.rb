class RemovePreviousActiveLocationIdsFromVendors < ActiveRecord::Migration
  def change
    remove_column :vendors, :previous_active_location_ids, :string
  end
end
