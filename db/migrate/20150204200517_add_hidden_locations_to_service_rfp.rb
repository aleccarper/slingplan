class AddHiddenLocationsToServiceRfp < ActiveRecord::Migration
  def change
    add_column :service_rfps, :hidden_locations, :text
  end
end
