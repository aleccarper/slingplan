class IndexLocationsServices < ActiveRecord::Migration
  def up
    add_index :locations_services, [:location_id, :service_id]
    add_index :locations_services, :service_id
  end

  def down
    remove_index :locations_services, [:location_id, :service_id]
    remove_index :locations_services, :service_id
  end
end
