class AddConfirmedToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :confirmed, default: false
    end
  end
end
