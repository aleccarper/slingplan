class AddSqlForInsertToSeedUploads < ActiveRecord::Migration
  def change
    change_table :seed_uploads do |t|
      t.text :sql_for_insert
    end
  end
end
