class AddUserToNegotiations < ActiveRecord::Migration
  def change
    add_reference :negotiations, :user, index: true
  end
end
