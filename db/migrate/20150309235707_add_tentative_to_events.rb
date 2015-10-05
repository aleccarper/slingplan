class AddTentativeToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.boolean :tentative, default: false
    end
  end
end
