class CreateLocationsServicesJoinTable < ActiveRecord::Migration
  def change
    create_table :locations_services, id: false do |t|
      t.integer :location_id
      t.integer :service_id
    end
  end
end
