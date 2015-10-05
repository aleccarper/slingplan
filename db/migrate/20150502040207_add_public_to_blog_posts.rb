class AddPublicToBlogPosts < ActiveRecord::Migration
  def change
    add_column :blog_posts, :is_public, :boolean, default: false
  end
end
