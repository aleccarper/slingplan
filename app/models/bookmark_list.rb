class BookmarkList < ActiveRecord::Base
  belongs_to :planner
  has_many :bookmarks, dependent: :destroy

  validates :planner, presence: true
  validates :name, presence: true
end
