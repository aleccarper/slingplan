class AddUuidToNegotiations < ActiveRecord::Migration
  def change
    add_column :negotiations, :uuid, :uuid, default: 'uuid_generate_v4()'
  end
end
