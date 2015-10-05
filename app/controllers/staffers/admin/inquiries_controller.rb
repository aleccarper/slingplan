class Staffers::Admin::InquiriesController < Staffers::AdminController
  include Staffers::Admin::InquiriesHelper

  before_action :before_stream, only: [
    :stream
  ]

  def index
    set_meta_tags :title => 'Help'
  end

  def page_open
    render_pagination current_staffer.inquiries.open.with_unread_first(:admin).get_pages
  end

  def page_closed
    render_pagination current_staffer.inquiries.closed.with_unread_first(:admin).get_pages
  end

  def stream
    inquiry = Inquiry.find(params[:id])
    last_updated = inquiry.messages.last_updated.first
    stream_results(last_updated, 'message_list', {
      inquiry: inquiry
    })
  end



  private

  def before_stream
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Content-Type'] = 'text/event-stream'
    @sse = Reloader::SSE.new(response.stream)
  end

  def stream_results(last_updated, partial, locals)
    if last_updated and recently_changed? last_updated
      view = render_to_string({
        partial: partial,
        formats: [:html],
        locals: locals
      })
      @sse.write({ view: view }, event: 'results')
    end
  ensure
    @sse.close
  end

  def params_for_inquiry
    params.require(:inquiry).permit(
      :staffer_id,
      :subject,
      :body
    )
  end
end
