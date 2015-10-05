class PlannerMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def planner_payment_email(planner, charge)
    @no_reply = true
    @planner = planner
    @charge = charge
    mail(to: @planner.email, subject: 'Your payment was successful!')
  end

  def planner_payment_failed_email(planner)
    @no_reply = true
    @planner = planner
    mail(to: @planner.email, subject: 'Your payment has failed')
  end

  def planner_subscription_ended_email(planner)
    @no_reply = true
    @planner = planner
    mail(to: @planner.email, subject: 'Your subscription has ended')
  end

  def planner_welcome_email(planner)
    @no_reply = true
    @planner = planner

    if BlogPost.count > 0
      @blog_post_url = "/blog/#{BlogPost.first.id}"
    end
    mail(to: @planner.email, subject: 'Welcome to SlingPlan!')
  end
end


