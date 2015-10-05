class RemoveAcceptedTosToVendors < ActiveRecord::Migration
  def change
    remove_column :vendors, :accepted_tos, :boolean
  end
end
