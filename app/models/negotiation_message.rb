class NegotiationMessage < ActiveRecord::Base
  belongs_to :negotiation

  belongs_to :vendor
  belongs_to :planner

  has_attached_file :file_attachment
  do_not_validate_attachment_file_type :file_attachment

  validate :vendor_xor_planner
  validate :content_xor_file_attachment_xor_bid_xor_revoke_xor_approve

  validates :negotiation, presence: true

  validates :bid, allow_blank: true,
    format: {
      with: /(\d*)/
    },
    numericality: {
      greater_than: 0,
      only_integer: true
    }

  validate :bid_less_than_budget

  scope :last_updated, -> {
    order('updated_at DESC, created_at DESC').limit(1)
  }

  after_initialize :after_initialize
  after_create :after_create

  def owner
    vendor or planner
  end

  def read!
    self.update_attribute(:read, true)
  end

  def read?
    read
  end

  def other_party
    if owner.class == Vendor
      return negotiation.vendor_rfp.service_rfp.event.owner
    elsif owner.class == Planner
      return negotiation.vendor_rfp.location.owner
    end
  end



  private

  def after_initialize
    self.bid ||= nil
  end

  def after_create
    status = case action
    when 'reply', 'bid' then nil
    when 'revoke' then 'open'
    when 'approve' then 'closed'
    end

    if status != nil
      negotiation.update_attribute(:status, status)
    end

    self.reload

    case action
    when 'reply'
      NegotiationNotifier.negotiation_message_created(self.reload)
      NegotiationMailer.delay_for(15.seconds).negotiation_message_created(self.reload.id)
    when 'file'
      NegotiationNotifier.negotiation_file_created(self.reload)
      NegotiationMailer.delay_for(15.seconds).negotiation_file_created(self.reload.id)
    when 'bid'
      NegotiationNotifier.negotiation_bid_created(self.reload)
      NegotiationMailer.delay_for(15.seconds).negotiation_bid_created(self.reload.id)
    when 'revoke'
      NegotiationNotifier.negotiation_revoked(self.reload)
      NegotiationMailer.delay_for(15.seconds).negotiation_revoked(self.reload.id)
    when 'approve'
      NegotiationNotifier.negotiation_bid_approved(self.reload)
      NegotiationMailer.delay_for(15.seconds).negotiation_bid_approved(self.reload.id)

      # Message other vendors when bid accepted
      # iterate every vendor RFP under the service RFP containing the current vendor RFP
      self.negotiation.vendor_rfp.service_rfp.vendor_rfps.each do |vrfp|
        # skip vendor RFP if is the current one
        next if vrfp == self.negotiation.vendor_rfp
        # new message within other vendor RFP
        msg = NegotiationMessage.new.tap do |m|
          m.negotiation_id = vrfp.negotiation.id
          m.planner_id = vrfp.service_rfp.event.planner.id
          m.action = 'reply'
          m.content = "[Automated Message] The planner has accepted another bid for #{vrfp.service_rfp.service.name}, but bids may still be placed in case the agreement is revoked."
        end
        msg.save
      end
    end
  end

  def bid_less_than_budget
    rfp = negotiation.vendor_rfp.service_rfp

    return if rfp.budget.nil? or bid.nil?

    if bid > rfp.budget
      errors.add(:bid, "exceeds #{rfp.service.name} budget")
    end
  end

  def vendor_xor_planner
    if vendor_id.blank? and planner_id.blank?
      errors.add(:base, "Negotiation Message must have a vendor or planner")
    end
  end

  def content_xor_file_attachment_xor_bid_xor_revoke_xor_approve
    if self.content.blank? and self.file_attachment.blank? and self.bid.blank? and not ['revoke', 'approve'].include? action
      errors.add(:base, "Negotiation Message must have content, a file attachment, a bid, or a revokation")
    end
  end
end
