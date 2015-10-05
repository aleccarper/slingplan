class Settings < ActiveRecord::Base
  belongs_to :planner
  belongs_to :vendor
  belongs_to :staffer

  enum email_frequency: [
    :realtime,
    # :daily,
    :never
  ]
end
