class AddAdminToSeedUploads < ActiveRecord::Migration
  def change
    change_table :seed_uploads do |t|
      t.references :admin, index: true
    end
  end
end
