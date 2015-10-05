class AddPrimaryPhoneEmailAndWebsiteToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :primary_phone_number, :string
    add_column :vendors, :primary_email, :string
    add_column :vendors, :primary_website, :string
  end
end
