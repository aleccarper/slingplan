class AddLogoImageToUsers < ActiveRecord::Migration
  def self.up
    add_attachment :users, :logo_image
  end

  def self.down
    remove_attachment :users, :logo_image
  end
end
