class AddAcceptedTermsOfServiceToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :accepted_terms_of_service, :boolean
  end
end
