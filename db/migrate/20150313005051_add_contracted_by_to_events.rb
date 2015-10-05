class AddContractedByToEvents < ActiveRecord::Migration
  def change
    add_column :events, :contracted_by, :string
  end
end
