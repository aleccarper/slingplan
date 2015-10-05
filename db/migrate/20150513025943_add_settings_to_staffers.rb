class AddSettingsToStaffers < ActiveRecord::Migration
  def change
    change_table :settings do |t|
      t.references :staffer, index: true
    end
  end
end
