class AddBillingStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_status, :string, default: 'active'
  end
end
