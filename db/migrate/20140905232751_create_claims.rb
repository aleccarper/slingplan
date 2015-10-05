class CreateClaims < ActiveRecord::Migration
  def change
    create_table :claims do |t|
      t.references :vendor, index: true
      t.references :location, index: true
    end
  end
end
