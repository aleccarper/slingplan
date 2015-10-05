class LogController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def client_events
    JSON.parse(params[:client_events]).each do |e|
      c = ClientEvent.new({
        ip: request.remote_ip,
        time: e['time'],
        path: e['path'],
        html_id: e['html_id'],
        html_class: e['html_class'],
        event_type: e['event_type']
      })
      c.vendor = current_vendor if vendor_signed_in?
      c.save if c.valid?
    end
    head :ok
  end
end
