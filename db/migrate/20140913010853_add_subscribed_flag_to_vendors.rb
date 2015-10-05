class AddSubscribedFlagToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :subscribed, :bool, default: false
  end
end
