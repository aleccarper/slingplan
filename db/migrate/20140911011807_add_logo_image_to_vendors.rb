class AddLogoImageToVendors < ActiveRecord::Migration
  def self.up
    add_attachment :vendors, :logo_image
  end

  def self.down
    remove_attachment :vendors, :logo_image
  end
end
