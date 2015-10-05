class NegotiationNotifier

  def self.negotiation_created(negotiation)
    Notifier::Manager::notify(negotiation.vendor_rfp.location.owner, 'Negotiation Created', created_message(negotiation), negotiation.vendor_path, 1)
  end

  def self.negotiation_message_created(message)
    Notifier::Manager::notify(message.other_party, 'Negotiation Reply Created', message.content, link_path(message), 1)
  end

  def self.negotiation_file_created(message)
    Notifier::Manager::notify(message.other_party, 'Negotiation File Uploaded', message.file_attachment_file_name, link_path(message), 1)
  end

  def self.negotiation_bid_created(message)
    Notifier::Manager::notify(message.other_party, 'Negotiation Bid Created', "$#{message.bid}", link_path(message), 2)
  end

  def self.negotiation_revoked(message)
    Notifier::Manager::notify(message.other_party, 'Negotiation Bid Revoked', message.content, link_path(message), 2)
  end

  def self.negotiation_bid_approved(message)
    Notifier::Manager::notify(message.other_party, 'Negotiation Bid Approved', message.content, link_path(message), 2)
  end



  private

  def self.created_message(negotiation)
    if negotiation.vendor_rfp.service_rfp.notes.blank?
      return negotiation.vendor_rfp.service_rfp.service.name
    else
      return negotiation.vendor_rfp.service_rfp.notes
    end
  end

  def self.link_path(message)
    if message.owner.class == Planner
      return message.negotiation.vendor_path
    elsif message.owner.class == Vendor
      return message.negotiation.planner_path
    end
  end
end
