require 'reloader/sse'

class Admin::InquiriesController < ApplicationController
  include Admin::InquiriesHelper
  include ActionController::Live
  layout 'admin'

  before_action :before_stream, only: [
    :stream,
    :stream_new_message_buttons
  ]

  def index
  end

  def page_open
    render_pagination Inquiry.closed.with_unread_first([:vendor, :planner]).get_pages
  end

  def page_closed
    render_pagination Inquiry.open.with_unread_first([:vendor, :planner]).get_pages
  end


  def watch
  end

  def stream
    inquiry = Inquiry.find(params[:id])
    last_updated = inquiry.messages.last_updated.first
    stream_results(last_updated, 'message_list', {
      inquiry: inquiry
    })
  end

  def stream_new_message_buttons
    inquiry = Inquiry.find(params[:id])
    last_updated = inquiry.messages.last_updated.first
    stream_results(last_updated, 'new_message_buttons', {
      inquiry: inquiry
    })
  end

  def create_message
    @msg = InquiryMessage.new(params_for_inquiry_message.merge({
      admin_id: current_admin.id,
      action: message_action
    }))

    @msg.save

    render json: {
      success: @msg.errors.blank?,
      error: @msg.errors.full_messages.first
    }
  end

  def reopen
    inquiry = Inquiry.find(params[:id])
    inquiry.status = 'open'
    inquiry.save

    redirect_to @msg.inquiry.admin_path
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

  def message_action
    [:reply, :closed, :open].map { |s|
      if params.include? s then s.to_s else nil end
    }.compact.first
  end

  def params_for_inquiry_message
    params.require(:inquiry_message).permit(
      :inquiry_id,
      :content
    )
  end

  def recently_changed? last
    last.created_at > 5.seconds.ago or last.updated_at > 5.seconds.ago
  end

end
