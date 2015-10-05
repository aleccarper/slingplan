class RemoveOpenCloseTimeFromLocations < ActiveRecord::Migration
  def up
    remove_column :locations, :open_time, :string
    remove_column :locations, :close_time, :string
  end

  def down
    add_column :locations, :open_time, :string
    add_column :locations, :close_time, :string
  end
end
