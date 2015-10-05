class Notification < ActiveRecord::Base
  belongs_to :vendor, foreign_key: 'vendor_id'
  belongs_to :planner, foreign_key: 'planner_id'
  belongs_to :staffer, foreign_key: 'staffer_id'

  scope :last_updated, -> {
    order('updated_at DESC, created_at DESC').limit(1)
  }

  scope :unread, -> {
    where(read: false)
  }
end
