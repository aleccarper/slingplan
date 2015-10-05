class ClaimsMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def new_claim_notification_email(admin_id, claim_id)
    @no_reply = true
    @admin = Admin.find_by_id(admin_id)
    @claim = Claim.find_by_id(claim_id)
    mail(to: @admin.email, subject: 'A new location claim has been filed')
  end

  def canceled_claim_notification_email(admin_id, claim_id)
    @no_reply = true
    @admin = Admin.find_by_id(admin_id)
    @claim = Claim.find_by_id(claim_id)
    mail(to: @admin.email, subject: 'A location claim has been canceled')
  end

  def claim_approved_notification(vendor_id, claim_id)
    @no_reply = true
    @vendor = Vendor.find_by_id(vendor_id)
    @claim = Claim.find_by_id(claim_id)
    mail(to: @vendor.email, subject: 'Your locatoin claim has been approved!')
  end

  def claim_denied_notification(vendor_id, claim_id)
    @no_reply = true
    @vendor = Vendor.find_by_id(vendor_id)
    @claim = Claim.find_by_id(claim_id)
    mail(to: @vendor.email, subject: 'Your location claim has been denied');
  end
end
