class CreateVendorRfps < ActiveRecord::Migration
  def change
    create_table :vendor_rfps do |t|
      t.references :service_rfp, index: true
      t.references :location, index: true
    end
  end
end
