class AddSubscriptionIdToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :subscription_id, :string
  end
end
