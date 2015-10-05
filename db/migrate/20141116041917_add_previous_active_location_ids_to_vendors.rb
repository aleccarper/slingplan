class AddPreviousActiveLocationIdsToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :previous_active_location_ids, :string
  end
end
