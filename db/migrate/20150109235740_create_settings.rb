class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.references :planner, index: true
      t.references :vendor, index: true

      t.integer :email_frequency, default: 0

      t.timestamps
    end
  end
end
