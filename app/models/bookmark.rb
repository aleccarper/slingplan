class Bookmark < ActiveRecord::Base
  belongs_to :bookmark_list
  belongs_to :location

  validates :bookmark_list, presence: true
end
