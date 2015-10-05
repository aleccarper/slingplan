class AddCountryCodeToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :country_code, :string
  end
end
