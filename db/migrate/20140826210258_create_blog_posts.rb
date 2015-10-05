class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.belongs_to :admin
      t.text :content


      t.timestamps
    end
  end
end
