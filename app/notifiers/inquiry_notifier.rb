class InquiryNotifier

  def self.inquiry_created(inquiry)
    Notifier::Manager::notify(Admin.all.to_a, 'Inquiry Created', inquiry.subject, inquiry.admin_path, 3)
  end

  def self.inquiry_message_created(message)
    Notifier::Manager::notify(message.other_party, 'Inquiry Reply Created', message.content, link_path(message), 2)
  end

  def self.inquiry_reopen(message)
    Notifier::Manager::notify(message.other_party, 'Inquiry Reopened', message.content, link_path(message), 2)
  end

  def self.inquiry_closed(message)
    Notifier::Manager::notify(message.other_party, 'Inquiry Closed', message.content, link_path(message), 2)
  end



  private

  def self.link_path(message)
    if message.owner.class == Admin
      if message.inquiry.owner.class == Planner
        return message.inquiry.planner_path
      elsif message.inquiry.owner.class == Vendor
        return message.inquiry.vendor_path
      end
    elsif [Vendor, Planner].include? message.owner.class
      return message.inquiry.admin_path
    end
  end
end
