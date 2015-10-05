class Vendors::Admin::Locations::EventsController < Vendors::Admin::LocationsController

  before_action {
    @location = current_vendor.locations.find_by_id(params[:id])
    @event = Event.where('id IN (?)', Location.location_events(params[:id]).map(&:first))
  }

  def manage
    @event = Event.find(params[:event_id])
    negotiation_ids = VendorRfp.under_event_for_location(@event.id, @location.id).map(&:second)
    @negotiations = Negotiation.where('id IN (?)', negotiation_ids || [])
  end

  def page_today
    render_pagination @event.today.get_pages, nil, { location: @location }
  end

  def page_future
    render_pagination @event.future.get_pages, nil, { location: @location }
  end

  def page_past
    render_pagination @event.past.get_pages, nil, { location: @location }
  end

end
