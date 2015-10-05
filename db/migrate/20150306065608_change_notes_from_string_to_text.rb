class ChangeNotesFromStringToText < ActiveRecord::Migration
  def up
    change_column :service_rfps, :notes, :text
  end

  def down
    change_column :service_rfps, :notes, :string
  end
end
