class NegotiationMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  # notify vendor of negotiation
  def negotiation_created(negotiation_id)
    @message = nil
    @negotiation = Negotiation.find_by_id(negotiation_id)
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation Created (\##{@negotiation.id})"
    })
  end

  # notify planner of vendor's bid
  def negotiation_bid_created(message_id)
    @message = NegotiationMessage.find_by_id(message_id)
    @negotiation = @message.negotiation
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation Bid Created (\##{@negotiation.id})"
    })
  end

  # notify planner or vendor of file upload
  def negotiation_file_created(message_id)
    @message = NegotiationMessage.find_by_id(message_id)
    @negotiation = @message.negotiation
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation File Created (\##{@negotiation.id})"
    })
  end

  # notify vendor or planner's bid approval
  def negotiation_bid_approved(message_id)
    @message = NegotiationMessage.find_by_id(message_id)
    @negotiation = @message.negotiation
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation Bid Approved (\##{@negotiation.id})"
    })
  end

  # if planner reopened then notify vendor, or if vendor reopened notify planner
  def negotiation_revoked(message_id)
    @message = NegotiationMessage.find_by_id(message_id)
    @negotiation = @message.negotiation
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation Revoked (\##{@negotiation.id})"
    })
  end

  def negotiation_message_created(message_id)
    @message = NegotiationMessage.find_by_id(message_id)
    @negotiation = @message.negotiation
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Negotiation Reply Created (\##{@negotiation.id})"
    })
  end



  private

  def mail_if_settings_permit(hash)
    mail hash unless recipient.settings.email_frequency == 'never'
  end

  def reply_to
    "#{recipient_class.downcase}-negotiation-#{@negotiation.uuid}@mail.slingplan.com"
  end

  def set_page_path
    if @message.blank?
      return @page_path = @negotiation.vendor_path
    end
    if @message.owner.class == Planner
      @page_path = @negotiation.vendor_path
    elsif @message.owner.class == Vendor
      @page_path = @negotiation.planner_path
    end
  end

  def recipient_email
    if @message.blank?
      return @negotiation.vendor_rfp.location.owner.email
    end
    if @message.owner.class == Planner
      return @negotiation.vendor_rfp.location.owner.email
    elsif @message.owner.class == Vendor
      return @negotiation.owner.email
    end
  end

  def recipient
    @vendor = @negotiation.vendor_rfp.location.owner
    return @vendor if @message.blank?
    return @negotiation.vendor_rfp.location.owner if @message.owner.class == Planner
    return @negotiation.owner if @message.owner.class == Vendor
  end

  def recipient_class
    recipient.class.name
  end
end
