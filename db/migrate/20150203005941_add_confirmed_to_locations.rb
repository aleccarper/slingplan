class AddConfirmedToLocations < ActiveRecord::Migration
  def change
    change_table :locations do |t|
      t.boolean :confirmed, default: false
    end
  end
end
