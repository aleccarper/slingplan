class AddRadiusToServiceRfps < ActiveRecord::Migration
  def change
    add_column :service_rfps, :radius, :integer
  end
end
