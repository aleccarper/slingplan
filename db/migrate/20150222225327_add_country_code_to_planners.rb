class AddCountryCodeToPlanners < ActiveRecord::Migration
  def change
    add_column :planners, :country_code, :string
  end
end
