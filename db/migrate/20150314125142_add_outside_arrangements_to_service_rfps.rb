class AddOutsideArrangementsToServiceRfps < ActiveRecord::Migration
  def change
    add_column :service_rfps, :outside_arrangements, :boolean, default: false
  end
end
