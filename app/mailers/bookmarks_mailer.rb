class BookmarksMailer < ActionMailer::Base
  layout 'mailer'
  default from: "notifications@slingplan.com", from_name: "SlingPlan"

  add_template_helper(ApplicationHelper)
  add_template_helper(MailerHelper)

  def export(email, ids)
    @no_reply = true
    @ids = ids
    mail(to: email, subject: 'SlingPlan Bookmarks')
  end
end
