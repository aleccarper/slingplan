class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.references :bookmark_list, index: true
      t.references :location, index: true
    end
  end
end
