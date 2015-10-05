class RenameKeywordsToDescriptionOnServices < ActiveRecord::Migration
  def up
    rename_column :services, :key_words, :description
  end

  def down
    rename_column :services, :description, :key_words
  end
end
