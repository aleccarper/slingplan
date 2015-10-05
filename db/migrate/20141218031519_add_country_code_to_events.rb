class AddCountryCodeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :country_code, :string
  end
end
