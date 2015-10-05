class Negotiation < ActiveRecord::Base
  self.inheritance_column = nil

  belongs_to :planner
  belongs_to :vendor_rfp

  has_many :messages, class_name: 'NegotiationMessage', dependent: :destroy

  validate :planner, presence: true
  validates :status, presence: true

  def self.per_page; 4 end
  scope :get_pages, -> { all.in_groups_of(Negotiation.per_page).map(&:compact) }
  scope :get_page, lambda { |p| get_pages[p.to_i] }

  scope :open, -> { where(status: 'open').recent_first }
  scope :closed, -> { where(status: 'closed').recent_first }
  scope :recent_first, -> { order(created_at: :desc) }

  after_create :after_create

  def after_create
    self.reload
    # we call reload on self here to make sure uuid is loaded
    NegotiationNotifier.negotiation_created(self.reload)
    NegotiationMailer.delay.negotiation_created(self.reload.id)
  end

  def owner
    planner
  end

  def vendor
    vendor_rfp.location.vendor
  end

  def vendor_path
    "/vendors/admin/inquiries/negotiations/#{self.id}"
  end

  def planner_path
    "/planners/admin/inquiries/negotiations/#{self.id}"
  end

  def type
    'negotiation'
  end



  def is_open?
    self.status == 'open'
  end

  def is_closed?
    self.status == 'closed'
  end
end
