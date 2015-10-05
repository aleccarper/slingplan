class Inquiry < ActiveRecord::Base
  extend OrderAsSpecified

  self.inheritance_column = nil

  belongs_to :vendor
  belongs_to :planner
  belongs_to :staffer

  has_many :messages, class_name: 'InquiryMessage', dependent: :destroy

  validate :vendor_xor_planner_xor_staffer

  validates :type, presence: true
  validates :status, presence: true
  validates :subject, presence: true
  validates :body, presence: true

  def self.per_page; 4 end
  scope :get_pages, -> { all.in_groups_of(Inquiry.per_page).map(&:compact) }
  scope :get_page, lambda { |p| get_pages[p.to_i] }

  scope :suggestions, -> { where(type: 'suggestion').recent_first }
  scope :questions, -> { where(type: 'question').recent_first }
  scope :bug_reports, -> { where(type: 'bug_report').recent_first }
  scope :open, -> { where(status: 'open').recent_first }
  scope :closed, -> { where(status: 'closed').recent_first }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :with_unread_first, lambda { |model|
    cond = if model.class == Array
      "#{model[0]}_id IS NOT NULL OR #{model[1]}_id IS NOT NULL"
    else
      "#{model}_id IS NOT NULL"
    end

    m = model.class == Array ? model[0] : model
    ids = all.sort { |a, b|
      a.unread_messages_for(m).where(cond).count <=> b.unread_messages_for(m).where(cond).count
    }.map(&:id)

    where('id IN (?)', ids).order_as_specified(id: ids).reverse_order || []
  }

  after_create :after_create

  def after_create
    self.reload
    # we call reload on self here to make sure uuid is loaded
    InquiryNotifier.inquiry_created(self.reload)
    InquiryMailer.delay_for(15.seconds).inquiry_created(self.id)
  end

  def owner
    vendor || planner || staffer
  end

  def admin_path
    "/admin/inquiries/#{self.type}s/#{self.id}"
  end

  def vendor_path
    "/vendors/admin/inquiries/#{self.type}s/#{self.id}"
  end

  def planner_path
    "/planners/admin/inquiries/#{self.type}s/#{self.id}"
  end

  def staffer_path
    "/staffers/admin/inquiries/#{self.type}s/#{self.id}"
  end

  def unread_messages_for(model)
    messages.where("#{model.to_s}_id".to_sym => nil).where(read: false)
  end

  def has_unread_messages_for?(model)
    !unread_messages_for(model).blank?
  end



  def is_open?
    self.status == 'open'
  end

  def is_closed?
    self.status == 'closed'
  end


  private

  def vendor_xor_planner_xor_staffer
    if vendor_id.blank? && planner_id.blank? && staffer_id.blank?
      errors.add(:base, "Inquiry Message must have a vendor, planner, or staffer.")
    end
  end
end
