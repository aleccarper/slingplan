class AddStatusToClaims < ActiveRecord::Migration
  def change
    add_column :claims, :status, :string, default: 'pending'
  end
end
