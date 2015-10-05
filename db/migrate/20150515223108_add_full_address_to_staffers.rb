class AddFullAddressToStaffers < ActiveRecord::Migration
  def change
    add_column :staffers, :full_address, :string
  end
end
