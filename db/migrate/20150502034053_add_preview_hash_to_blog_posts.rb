class AddPreviewHashToBlogPosts < ActiveRecord::Migration
  def change
    change_table :blog_posts do |t|
      t.string :preview_hash
    end
  end
end
