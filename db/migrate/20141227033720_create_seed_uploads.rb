class CreateSeedUploads < ActiveRecord::Migration
  def change
    create_table :seed_uploads do |t|
      t.attachment :file

      t.timestamps
    end
  end
end
