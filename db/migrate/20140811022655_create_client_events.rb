class CreateClientEvents < ActiveRecord::Migration
  def change
    create_table :client_events do |t|
      t.references :vendor

      t.string :path
      t.string :html_id
      t.string :html_class
      t.string :event_type

      t.timestamps
    end
  end
end
