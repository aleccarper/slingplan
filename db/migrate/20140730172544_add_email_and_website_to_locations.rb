class AddEmailAndWebsiteToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :website, :string
    add_column :locations, :email, :string
  end
end
