class RemoveServiceRfpFromService < ActiveRecord::Migration
  def up
    remove_column :services, :service_rfp_id, :integer
  end

  def down
    add_column :services, :service_rfp_id, :integer
  end
end
