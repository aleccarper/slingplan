class CreateEventsServicesJoinTable < ActiveRecord::Migration
  def change
    create_table :events_services, id: false do |t|
      t.integer :event_id
      t.integer :service_id
    end
  end
end
