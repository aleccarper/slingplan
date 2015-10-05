module Planners::Admin::EventsHelper

  def events_area(&block)
    content = capture(&block)
    cls = 'events'

    max = get_max_allowed_events(planner_subscription)

    unless max == 'Unlimited'
      cls << ' max-allowed' if @total_events >= max
    end

    content_tag :div, content, class: cls
  end

  def get_eligible_services
    eligible = Location.near(@event.full_address, 200)
      .vendor_owned
      .account_valid
      .active
      .includes(:services)
      .references(:services)
      .map(&:services)
      .flatten
      .uniq
    Service.all.partition { |s| eligible.include? s }
  end

  def active_events_ratio
    tier_id = planner_subscription
    term = tier_id[5..-1]
    current = @total_events
    max = get_max_allowed_events(tier_id)

    percentage = ((current.to_f / max) * 100).to_i

    content_tag(:div, class: 'event-totals') do
      concat content_tag(:div, '', class: 'used', data: { percentage: percentage })
      concat event_ratio_text(current, max, tier_id, term)
    end
  end

  def event_list_address(event)
    content_tag :div, class: 'event-address' do
      concat content_tag(:div, event.address1, class: 'event-address1')
      if event.address2
        concat content_tag(:div, event.address2, class: 'event-address2')
      end
      concat content_tag(:span, "#{event.city}, ", class: 'event-city')
      concat content_tag(:span, "#{event.state} ", class: 'event-state')
      concat content_tag(:span, event.zip, class: 'event-zip')
    end
  end

  def event_slider(event, &block)
    content = capture(&block)
    cls = 'event-active slider'
    cls << ' inactive' if event.status != 'active'

    content_tag :div, content, class: cls
  end



  private

  def event_ratio_text(current, max, tier_id, term)
    content_tag(:div, class: 'text') do
      concat content_tag(:span, "#{current}/#{max}", class: 'current-max')
      concat content_tag(:span, ' events')
    end
  end
end
