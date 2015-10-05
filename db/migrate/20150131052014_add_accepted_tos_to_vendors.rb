class AddAcceptedTosToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :accepted_tos, :boolean
  end
end
