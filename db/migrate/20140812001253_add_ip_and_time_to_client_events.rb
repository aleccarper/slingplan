class AddIpAndTimeToClientEvents < ActiveRecord::Migration
  def change
    add_column :client_events, :ip, :string
    add_column :client_events, :time, :string
  end
end
