class AddStripeCustomerIdToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :stripe_id, :string
  end
end
