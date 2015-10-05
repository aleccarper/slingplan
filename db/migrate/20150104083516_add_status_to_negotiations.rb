class AddStatusToNegotiations < ActiveRecord::Migration
  def change
    change_table :negotiations do |t|
      t.string :status, default: 'open'
    end
  end
end
