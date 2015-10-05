class AddServiceRfpToServices < ActiveRecord::Migration
  def change
    change_table :services do |t|
      t.references :service_rfp, index: true
    end
  end
end
