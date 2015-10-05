class CreateStaffers < ActiveRecord::Migration
  def change
    create_table :staffers do |t|

      t.timestamps
    end
  end
end
