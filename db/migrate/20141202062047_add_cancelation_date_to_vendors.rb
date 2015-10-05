class AddCancelationDateToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :cancelation_date, :string
  end
end
