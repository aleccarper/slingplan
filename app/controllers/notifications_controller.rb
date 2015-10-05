class NotificationsController < ApplicationController

  def stream
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Content-Type'] = 'text/event-stream'
    @sse = Reloader::SSE.new(response.stream)

    notifications = []
    model = current_vendor || current_planner

    if model && model.respond_to?(:notifications)
      notifications = model.notifications.order('id DESC')

      last_updated = notifications.last_updated.first

      if last_updated and recently_changed? last_updated
        view = render_to_string({
          partial: 'notifications/notifications',
          formats: [:html],
          locals: {
            notifications: notifications.unread
          }
        })
        @sse.write({ view: view }, event: 'results')
      end
    end
  ensure
    @sse.close
  end

  def read
    ids = params[:ids].nil? ? [params[:id]] : params[:ids]
    ids.each { |id|
      notification = Notification.find(id)
      if notification
        notification.read = true
        notification.save
      end
    }

    render nothing: true
  end
end
