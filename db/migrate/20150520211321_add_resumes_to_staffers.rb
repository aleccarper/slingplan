class AddResumesToStaffers < ActiveRecord::Migration
  def self.up
    add_attachment :staffers, :resume
  end

  def self.down
    remove_attachment :staffers, :resume
  end
end
