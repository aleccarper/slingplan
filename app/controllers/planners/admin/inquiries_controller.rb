class Planners::Admin::InquiriesController < Planners::AdminController
  include Planners::Admin::InquiriesHelper

  before_action :before_stream, only: [
    :stream,
    :stream_negotiation,
    :stream_vendor_rfp,
    :stream_new_negotiation_message_buttons
  ]

  def index
    set_meta_tags :title => 'Help'
  end

  def page_open
    render_pagination current_planner.inquiries.open.with_unread_first(:admin).get_pages
  end

  def page_closed
    render_pagination current_planner.inquiries.closed.with_unread_first(:admin).get_pages
  end

  def stream
    inquiry = Inquiry.find(params[:id])
    last_updated = inquiry.messages.last_updated.first
    stream_results(last_updated, 'message_list', {
      inquiry: inquiry
    })
  end

  def stream_negotiation
    negotiation = Negotiation.find(params[:id])
    last_updated = negotiation.messages.last_updated.first
    stream_results(last_updated, 'negotiation_message_list', {
      inquiry: negotiation
    })
  end

  def stream_vendor_rfp
    @vendor_rfp = VendorRfp.find(params[:id])
    @service_rfp = @vendor_rfp.service_rfp
    @event = @service_rfp.event
    last_updated = @vendor_rfp.negotiation.messages.last_updated.first
    stream_results(last_updated, '/inquiries/vendor_rfp', {
      rfp: @vendor_rfp
    })
  end

  def create_service_request
    event = Event.find_by_id(params[:event_id])
    services_requested = Service.where('id IN (?)', params[:service_ids])
    body = "[Automated Inquiry]\r\n\r\n"
    body << "Services:\r\n"
    body << services_requested.map { |s| ("&nbsp;" * 4) + "#{s.name}\r\n" }.join('')
    body << "\r\n"
    body << "Area Needed:\r\n"
    body << ("&nbsp;" * 4) + event.get_full_address
    @msg = Inquiry.new({
      planner_id: current_planner.id,
      is_service_request: true,
      type: 'suggestion',
      subject: 'Service Request',
      body: body
    })

    if @msg.save
      event.update_attribute(:service_request_submitted, true)
    end

    render json: {
      success: @msg.errors.blank?,
      error: @msg.errors.full_messages.first
    }
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
      :planner_id,
      :subject,
      :body
    )
  end
end
