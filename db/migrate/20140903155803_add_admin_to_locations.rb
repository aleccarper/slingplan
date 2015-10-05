class AddAdminToLocations < ActiveRecord::Migration
  def change
    add_reference :locations, :admin, index: true
  end
end
