class AddFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :phone_number, :string
    add_column :locations, :open_time, :string
    add_column :locations, :close_time, :string
  end
end
