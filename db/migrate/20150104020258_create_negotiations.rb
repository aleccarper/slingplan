class CreateNegotiations < ActiveRecord::Migration
  def change
    create_table :negotiations do |t|
      t.references :vendor_rfp, index: true
    end
  end
end
