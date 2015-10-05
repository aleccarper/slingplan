module Notifier
  class Manager
    def self.notify(recipient, title, message, link, priority)
      recipients = if recipient.class == Array then recipient else [recipient] end
      recipients.each do |r|
        if r.respond_to? :notifications
          r.notifications.create(
            title: title,
            message: message,
            link: link,
            priority: priority || 1
          )
        end
      end
    end
  end
end
