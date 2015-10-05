class AddServiceToServiceRfps < ActiveRecord::Migration
  def change
    change_table :service_rfps do |t|
      t.references :service, index: true
    end
  end
end
