class CreateServiceRfp < ActiveRecord::Migration
  def change
    create_table :service_rfps do |t|
      t.references :event, index: true
      t.integer :budget
      t.string :notes
    end
  end
end
