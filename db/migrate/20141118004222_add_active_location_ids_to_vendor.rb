class AddActiveLocationIdsToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :active_location_ids, :text
  end
end
