class LaunchSubscribersMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def new_launch_subscriber_email
    @no_reply = true
    mail(to: 'sean@criticalmechanism.com', subject: 'Launch Subscribers Backup')
  end
end
