class CreateBookmarkLists < ActiveRecord::Migration
  def change
    create_table :bookmark_lists do |t|
      t.references :planner, index: true
      t.string :name
    end
  end
end
