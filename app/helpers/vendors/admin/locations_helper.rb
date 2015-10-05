module Vendors::Admin::LocationsHelper

  def locations_area(&block)
    content = capture(&block)
    cls = 'locations'

    max = current_vendor.get_max_allowed_locations(vendor_subscription)
    unless max == 'Unlimited'
      cls << ' max-allowed' if @total_active_locations >= max
    end

    content_tag :div, content, class: cls
  end

  def active_locations_ratio
    tier_id = vendor_subscription
    term = tier_id[5..-1]
    current = @total_active_locations
    max = current_vendor.get_max_allowed_locations(tier_id)

    percentage = ((current.to_f / max) * 100).to_i

    content_tag(:div, class: 'location-totals') do
      concat content_tag(:div, '', class: 'used', data: { percentage: percentage })
      concat ratio_text(current, max, tier_id, term)
    end
  end

  def location_slider(location, &block)
    content = capture(&block)
    cls = 'location-active slider'
    cls << ' inactive' if location.status != 'active'

    content_tag :div, content, class: cls
  end



  private

  def ratio_text(current, max, tier_id, term)
    content_tag(:div, class: 'text') do
      concat content_tag(:span, "#{current}/#{max}", class: 'current-max')
      concat content_tag(:span, ' active locations')
    end
  end
end
