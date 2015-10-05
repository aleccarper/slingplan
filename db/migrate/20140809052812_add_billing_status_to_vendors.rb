class AddBillingStatusToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :billing_status, :string, :default => 'active'
  end
end
