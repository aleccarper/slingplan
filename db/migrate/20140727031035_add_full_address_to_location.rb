class AddFullAddressToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :full_address, :string
  end
end
