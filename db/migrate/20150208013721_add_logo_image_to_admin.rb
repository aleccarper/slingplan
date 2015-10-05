class AddLogoImageToAdmin < ActiveRecord::Migration
  def self.up
    add_attachment :admins, :logo_image
  end

  def self.down
    remove_attachment :admins, :logo_image
  end
end
