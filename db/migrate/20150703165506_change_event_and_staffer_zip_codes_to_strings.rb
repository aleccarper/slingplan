class ChangeEventAndStafferZipCodesToStrings < ActiveRecord::Migration
  def up
    change_column :events, :zip, :string
    change_column :staffers, :zip, :string
  end

  def down
    change_column :events, :zip, :integer
    change_column :staffers, :zip, :integer
  end
end
