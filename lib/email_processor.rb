class EmailProcessor

  def initialize(email)
    @email = email
  end

  def process
    # sender@example.com
    @from = @email.from[:email]
    # owner-subject-uuid@mail.slingplan.com
    @to = @email.to.first[:email]
    # http://rubular.com/r/Dj6hbKwnj1
    @tokens = @to.match /([\w]+)-([\w]+)-(.*)!?@/
    # turn string owner and subject into classes
    @author_class = Kernel.const_get(@tokens[1].classify)
    @subject_class = Kernel.const_get(@tokens[2].classify)
    # uuid identifying subject
    @uuid = @tokens[3]
    # parse out all text above the line and (hopefully) without signature
    @message = EmailReplyParser.parse_reply(@email.body)

    @author = @author_class.find_by(email: @from)

    if @subject_class == Inquiry
      @inquiry = Inquiry.find_by(uuid: @uuid)

      o = InquiryMessage.new
      o.inquiry = @inquiry
      o.content = @message
      o.action = 'reply'

      if @author.class == Vendor
        o.vendor = @author
      elsif @author.class == Planner
        o.vendor = @author
      elsif @author.class == Staffer
        o.staffer = @author
      elsif @author.class == Admin
        o.admin = @author
      end

      o.valid?
      o.save
    elsif @subject_class == Negotiation
      @negotiation = Negotiation.find_by(uuid: @uuid)

      o = NegotiationMessage.new
      o.negotiation = @negotiation
      o.content = @message
      o.action = 'reply'

      if @author.class == Vendor
        o.vendor = @author
      elsif @author.class == Planner
        o.planner = @author
      end

      o.valid?
      o.save
    end
  end
end
