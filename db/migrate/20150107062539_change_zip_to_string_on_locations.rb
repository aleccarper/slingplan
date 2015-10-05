class ChangeZipToStringOnLocations < ActiveRecord::Migration
  def up
    change_column :locations, :zip, :string
  end

  def down
    change_column :locations, :zip, :integer
  end
end
