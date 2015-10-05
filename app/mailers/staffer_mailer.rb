class StafferMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def staffer_payment_email(staffer, charge)
    @no_reply = true
    @staffer = staffer
    @charge = charge
    mail(to: @staffer.email, subject: 'Your payment was successful!')
  end

  def staffer_payment_failed_email(staffer)
    @no_reply = true
    @staffer = staffer
    mail(to: @staffer.email, subject: 'Your payment has failed')
  end

  def staffer_subscription_ended_email(staffer)
    @no_reply = true
    @staffer = staffer
    mail(to: @staffer.email, subject: 'Your subscription has ended')
  end

  def staffer_welcome_email(staffer)
    @no_reply = true
    @staffer = staffer

    if BlogPost.count > 0
      @blog_post_url = "/blog/#{BlogPost.first.id}"
    end
    mail(to: @staffer.email, subject: 'Welcome to SlingPlan!')
  end
end


