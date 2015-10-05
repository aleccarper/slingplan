class InquiryMessage < ActiveRecord::Base
  belongs_to :inquiry

  belongs_to :vendor
  belongs_to :admin
  belongs_to :planner
  belongs_to :staffer

  validate :has_owner?
  validate :cotent_or_nonreply_action

  has_attached_file :file_attachment

  scope :last_updated, -> {
    order('updated_at DESC, created_at DESC').limit(1)
  }

  after_create :after_create

  def owner
    vendor || admin || planner || staffer
  end

  def read!
    self.update_attribute(:read, true)
  end

  def read?
    read
  end

  def other_party
    if [Vendor, Planner].include? owner.class
      return Admin.all.to_a
    elsif owner.class == Admin
      return inquiry.owner
    end
  end



  private

  def after_create
    if action != 'reply'
      inquiry.update_attribute(:status, action)
    end

    self.reload

    case action
    when 'reply'
      InquiryNotifier.inquiry_message_created(self.reload)
      InquiryMailer.delay_for(15.seconds).inquiry_message_created(self.id)
    when 'open'
      InquiryNotifier.inquiry_reopen(self.reload)
      InquiryMailer.delay_for(15.seconds).inquiry_reopen(self.id)
    when 'closed'
      InquiryNotifier.inquiry_closed(self.reload)
      InquiryMailer.delay_for(15.seconds).inquiry_closed(self.id)
    end
  end

  def cotent_or_nonreply_action
    !content.blank? || (['open', 'closed'].include? action)
  end

  def has_owner?
    if vendor_id.blank? && planner_id.blank? && staffer_id.blank? && admin_id.blank?
      errors.add(:base, "Inquiry Message must have a vendor, admin, or planner.")
    end
  end
end
