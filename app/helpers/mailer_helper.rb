module MailerHelper

  def replyable?
    if defined? @no_reply
      if @no_reply
        return false
      end
    end
    true
  end

end
