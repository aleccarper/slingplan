class VendorMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def vendor_payment_email(vendor, charge)
    @no_reply = true
    @vendor = vendor
    @charge = charge

    mail(to: @vendor.email, subject: 'Your payment was successful!')
  end

  def vendor_payment_failed_email(vendor)
    @no_reply = true
    @vendor = vendor

    mail(to: @vendor.email, subject: 'Your payment has failed')
  end

  def vendor_subscription_ended_email(vendor)
    @no_reply = true
    @vendor = vendor

    mail(to: @vendor.email, subject: 'Your subscription has ended')
  end

  def vendor_trial_ended_email(vendor)
    @no_reply = true
    @vendor = vendor

    mail(to: @vendor.email, subject: 'Your first RFP!')
  end
end


