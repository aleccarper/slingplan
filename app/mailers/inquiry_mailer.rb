class InquiryMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def inquiry_created(inquiry_id)
    @message = nil
    @inquiry = Inquiry.find_by_id(inquiry_id)
    set_page_path

    mail_if_settings_permit({
      to: admin_emails,
      reply_to: reply_to,
      subject: "Inquiry Created (\##{@inquiry.id})"
    })
  end

  def inquiry_closed(message_id)
    @message = InquiryMessage.find_by_id(message_id)
    @inquiry = @message.inquiry
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Inquiry Closed (\##{@inquiry.id})"
    })
  end

  def inquiry_reopen(message_id)
    @message = InquiryMessage.find_by_id(message_id)
    @inquiry = @message.inquiry
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Inquiry Reopened (\##{@inquiry.id})"
    })
  end

  def inquiry_message_created(message_id)
    @message = InquiryMessage.find_by_id(message_id)
    @inquiry = @message.inquiry
    set_page_path

    mail_if_settings_permit({
      to: recipient_email,
      reply_to: reply_to,
      subject: "Inquiry Reply Created (\##{@inquiry.id})"
    })
  end



  private

  def mail_if_settings_permit(hash)
    if recipient_class == Admin
      mail hash
    else
      mail hash unless @inquiry.owner.settings.email_frequency == 'never'
    end
  end

  def reply_to
    "#{recipient_class.downcase}-inquiry-#{@inquiry.uuid}@mail.slingplan.com"
  end

  def admin_emails
    Admin.all.map(&:email).join(', ')
  end

  def set_page_path
    if @message.blank?
      return @page_path = @inquiry.admin_path
    end
    if @message.owner.class == Admin
      if @inquiry.owner.class == Vendor
        @page_path = @inquiry.vendor_path
      elsif @inquiry.owner.class == Planner
        @page_path = @inquiry.planner_path
      elsif @inquiry.owner.class == Staffer
        @page_path = @inquiry.staffer_path
      end
    elsif [Planner, Vendor, Staffer].include? @message.owner.class
      @page_path = @inquiry.admin_path
    end
  end

  def recipient_email
    if @message.blank?
      return admin_emails
    end
    if @message.owner.class == Admin
      return @inquiry.owner.email
    elsif [Planner, Vendor, Staffer].include? @message.owner.class
      return admin_emails
    end
  end

  def recipient_class
    cls = nil
    if @message.blank?
      return Admin.name
    end
    @other = @message.other_party
    if @other.class == Array
      cls = @message.owner.class
    else
      cls = Admin
    end
    cls.name
  end
end
