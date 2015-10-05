class AddHiddenHintsToPlannersAndVendors < ActiveRecord::Migration
  def change
    change_table :planners do |t|
      t.text :hidden_hints
    end
    change_table :vendors do |t|
      t.text :hidden_hints
    end
  end
end
