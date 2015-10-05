class AddAddressStuffToStaffers < ActiveRecord::Migration
  def change
    change_table :staffers do |t|
      t.string :address1
      t.string :address2
      t.string :city
      t.integer :zip
      t.string :state
      t.float :latitude
      t.float :longitude
    end
  end
end
