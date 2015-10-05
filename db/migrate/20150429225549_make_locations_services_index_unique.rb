class MakeLocationsServicesIndexUnique < ActiveRecord::Migration
  def up
    remove_index :locations_services, [:location_id, :service_id]
    add_index :locations_services, [:location_id, :service_id], unique: true
  end

  def down
    remove_index :locations_services, [:location_id, :service_id], unique: true
    add_index :locations_services, [:location_id, :service_id]
  end
end
